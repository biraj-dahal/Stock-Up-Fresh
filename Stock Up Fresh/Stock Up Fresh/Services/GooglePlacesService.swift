//
//  GooglePlacesService.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import Foundation
import CoreLocation

/// Represents one grocery/supermarket store from Google Places.
public struct StoreLocation: Identifiable, Codable {
    public let id: String
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double

    public init(
      id: String,
      name: String,
      address: String,
      latitude: Double,
      longitude: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Errors you might encounter when calling Google’s APIs
public enum GooglePlacesError: Error {
    case badURL
    case network(Error)
    case parsing(Error)
    case noResults
}

/// A thin wrapper for Google’s Places Nearby Search, returning *all* grocery_or_supermarket results.
public final class GooglePlacesService {
    private let apiKey: String
    private let session = URLSession.shared

    /// Reads your API key from Info.plist under “GoogleAPIKey”
    public init(apiKey: String = Bundle.main
                   .object(forInfoDictionaryKey: "GoogleAPIKey") as? String ?? "") {
        self.apiKey = apiKey
    }

    /// Fetches *all* grocery_or_supermarket around the given coordinate.
    /// - Parameters:
    ///   - coord: the user’s current location
    ///   - radiusMeters: search radius in meters (default 5 000)
    ///   - completion: result callback with an array of StoreLocation or a GooglePlacesError
    public func fetchNearbyGroceries(
        at coord: CLLocationCoordinate2D,
        radiusMeters: Int = 5000,
        completion: @escaping (Result<[StoreLocation], GooglePlacesError>) -> Void
    ) {


        // Build URL without any keyword filter
        let urlStr = """
        https://maps.googleapis.com/maps/api/place/nearbysearch/json\
        ?location=\(coord.latitude),\(coord.longitude)\
        &radius=\(radiusMeters)\
        &type=grocery_or_supermarket\
        &key=\(apiKey)
        """

        guard let url = URL(string: urlStr) else {
            return completion(.failure(.badURL))
        }

        session.dataTask(with: url) { data, _, error in
            if let netErr = error {
                print("🛰️ Network error:", netErr)
                return completion(.failure(.network(netErr)))
            }
            guard let data = data else {
                print("🛰️ No data returned from Places API")
                return completion(.failure(.noResults))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let status = (json?["status"] as? String) ?? "MISSING_STATUS"

                guard status == "OK",
                      let results = json?["results"] as? [[String:Any]],
                      !results.isEmpty
                else {
                    return completion(.failure(.noResults))
                }

                // Map to our StoreLocation struct
                let stores: [StoreLocation] = results.compactMap { place in
                    guard
                        let pid  = place["place_id"]   as? String,
                        let nm   = place["name"]       as? String,
                        let vic  = place["vicinity"]   as? String,
                        let geom = place["geometry"]   as? [String:Any],
                        let loc  = geom["location"]    as? [String:Any],
                        let lat  = loc["lat"]          as? Double,
                        let lng  = loc["lng"]          as? Double
                    else {
                        return nil
                    }
                    return StoreLocation(
                        id: pid,
                        name: nm,
                        address: vic,
                        latitude: lat,
                        longitude: lng
                    )
                }

                completion(.success(stores))
            } catch {
                print("🛰️ JSON parsing error:", error)
                completion(.failure(.parsing(error)))
            }
        }
        .resume()
    }
}
