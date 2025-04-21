//
//  LocationReminderManager.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import Foundation
import CoreLocation
import UserNotifications
import Combine

final class LocationReminderManager: NSObject, ObservableObject {
  static let shared = LocationReminderManager()
  
  private let locationManager = CLLocationManager()
  private let notificationCenter = UNUserNotificationCenter.current()
  public var cancellables = Set<AnyCancellable>()
  
  @Published var monitoredStores: [StoreLocation] = []
  
  private override init() {
    super.init()
    locationManager.delegate = self
    notificationCenter.delegate = self
    requestPermissions()
  }
  
  private func requestPermissions() {
    locationManager.requestAlwaysAuthorization()
    notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let err = error { print("Notif auth error:", err) }
    }
  }
  
  /// Call this after loading the user’s saved `stores`
  func startMonitoring(stores: [StoreLocation]) {
    // Stop any old regions
    for region in locationManager.monitoredRegions {
      locationManager.stopMonitoring(for: region)
    }
    monitoredStores = stores
    
    for store in stores {
      let center = CLLocationCoordinate2D(latitude: store.latitude,
                                          longitude: store.longitude)
      let region = CLCircularRegion(center: center,
                                    radius: 100,                          // e.g. 100 m
                                    identifier: store.id)
      region.notifyOnEntry = true
      region.notifyOnExit  = false
      locationManager.startMonitoring(for: region)
    }
  }
  
  private func handleStoreEntry(storeID: String) {
    guard let store = monitoredStores.first(where: { $0.id == storeID }) else {
      return
    }
    // 1) Fetch pantry items and thresholds
    let lowItems = PantryService.shared.items
      .filter { $0.quantity <= $0.threshold }
      .map(\.name)
    guard !lowItems.isEmpty else { return }
    
    // 2) Build notification
    let content = UNMutableNotificationContent()
    content.title = "You’re near \(store.name)"
    content.body = "Running low on: \(lowItems.joined(separator: ", "))"
    content.sound = .default
    
    // 3) Fire immediately
    let req = UNNotificationRequest(
      identifier: "stockup.reminder.\(store.id)",
      content: content,
      trigger: nil
    )
    notificationCenter.add(req) { error in
      if let err = error { print("Notif error:", err) }
    }
  }
}

extension LocationReminderManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
      case .authorizedAlways:
        print("Authorized Always")
      case .authorizedWhenInUse, .denied, .restricted:
        // Prompt user to go to Settings if you really need Always
        break
      default: break
    }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didEnterRegion region: CLRegion) {
    handleStoreEntry(storeID: region.identifier)
  }
  
  func locationManager(_ manager: CLLocationManager,
                       monitoringDidFailFor region: CLRegion?,
                       withError error: Error) {
    print("Monitoring failed for \(region?.identifier ?? "unknown"):", error)
  }
}

extension LocationReminderManager: UNUserNotificationCenterDelegate {
  // Show alerts even if app is foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    completion([.banner, .sound])
  }
}
