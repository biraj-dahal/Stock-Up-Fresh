//
//  GooglePlacesService.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//
import Foundation
import CoreLocation

struct StoreLocation: Identifiable, Codable {
  let id: String           // place_id from Google
  let name: String
  let address: String
  let latitude: Double
  let longitude: Double
}

enum GooglePlacesError: Error {
  case badURL, network(Error), parsing(Error), noResults
}

final class GooglePlacesService {
  private let apiKey: String
  private let session = URLSession.shared

  init(apiKey: String = Bundle.main.object(forInfoDictionaryKey: "GoogleAPIKey") as? String ?? "") {
    self.apiKey = apiKey
  }

  /// 1) Geocode the postal code, then 2) fetch nearby supermarkets.
  func fetchNearbyStores(
    postalCode: String,
    radiusMeters: Int = 5000,
    completion: @escaping (Result<[StoreLocation],GooglePlacesError>) -> Void
  ) {
    geocode(postalCode: postalCode) { result in
      switch result {
      case .failure(let err): completion(.failure(err))
      case .success(let coord):
        self.nearbySearch(at: coord, radius: radiusMeters) { completion($0) }
      }
    }
      
  }

  // MARK: – Geocoding
  private func geocode(
    postalCode: String,
    completion: @escaping (Result<CLLocationCoordinate2D,GooglePlacesError>) -> Void
  ) {
    let esc = postalCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? postalCode
    let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?address=\(esc)&key=\(apiKey)"
    guard let url = URL(string: urlStr) else { return completion(.failure(.badURL)) }

    session.dataTask(with: url) { data, _, err in
      if let e = err { return completion(.failure(.network(e))) }
      do {
        let json = try JSONSerialization.jsonObject(with: data!) as? [String:Any]
        guard
          let results = json?["results"] as? [[String:Any]],
          let locDict = results.first?["geometry"] as? [String:Any],
          let coordDict = locDict["location"] as? [String:Any],
          let lat = coordDict["lat"] as? Double,
          let lng = coordDict["lng"] as? Double
        else { return completion(.failure(.noResults)) }

        completion(.success(CLLocationCoordinate2D(latitude: lat, longitude: lng)))
      } catch {
        completion(.failure(.parsing(error)))
      }
    }.resume()
  }

  // MARK: – Nearby Search
  private func nearbySearch(
    at coord: CLLocationCoordinate2D,
    radius: Int,
    completion: @escaping (Result<[StoreLocation],GooglePlacesError>) -> Void
  ) {
    let urlStr = """
    https://maps.googleapis.com/maps/api/place/nearbysearch/json\
    ?location=\(coord.latitude),\(coord.longitude)\
    &radius=\(radius)\
    &type=grocery_or_supermarket\
    &key=\(apiKey)
    """
    guard let url = URL(string: urlStr) else { return completion(.failure(.badURL)) }

    session.dataTask(with: url) { data, _, err in
      if let e = err { return completion(.failure(.network(e))) }
      do {
        let json = try JSONSerialization.jsonObject(with: data!) as? [String:Any]
        guard let results = json?["results"] as? [[String:Any]], !results.isEmpty else {
          return completion(.failure(.noResults))
        }

        let stores: [StoreLocation] = results.compactMap { place in
          guard
            let placeID = place["place_id"] as? String,
            let name    = place["name"]     as? String,
            let vic     = place["vicinity"] as? String,
            let geom    = place["geometry"] as? [String:Any],
            let loc     = geom["location"]  as? [String:Any],
            let lat     = loc["lat"] as? Double,
            let lng     = loc["lng"] as? Double
          else { return nil }

          return StoreLocation(
            id: placeID,
            name: name,
            address: vic,
            latitude: lat,
            longitude: lng
          )
        }

        completion(.success(stores))
      } catch {
        completion(.failure(.parsing(error)))
      }
    }.resume()
  }
}

