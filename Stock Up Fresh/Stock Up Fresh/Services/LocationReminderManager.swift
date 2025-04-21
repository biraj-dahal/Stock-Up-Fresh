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

/// Manages geofence‐based reminders and one‑off location logging.
final class LocationReminderManager: NSObject, ObservableObject {
    static let shared = LocationReminderManager()

    // MARK: ‑‑ Published
    @Published var monitoredStores: [StoreLocation] = []
    @Published var lastKnownLocation: CLLocationCoordinate2D?

    // MARK: ‑‑ Internals
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    var cancellables = Set<AnyCancellable>()

    // MARK: ‑‑ Init
    private override init() {
        super.init()
        locationManager.delegate = self
        notificationCenter.delegate = self
        requestPermissions()
    }

    // MARK: ‑‑ Permissions
    private func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: ‑‑ Geofencing
    /// Start monitoring a list of stores (sets up CLCircularRegion for each).
    func startMonitoring(stores: [StoreLocation]) {
        // Stop any existing monitors
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredStores = stores

        // Create a 100m radius region for each store
        stores.forEach { store in
            let center = CLLocationCoordinate2D(latitude: store.latitude,
                                                longitude: store.longitude)
            let region = CLCircularRegion(center: center,
                                          radius: 100,
                                          identifier: store.id)
            region.notifyOnEntry = true
            region.notifyOnExit  = false
            locationManager.startMonitoring(for: region)
        }
    }

    // MARK: ‑‑ One‑off Location Logging
    /// Request a single location update and then log the 5 nearest stores.
    func logNearestStores() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // MARK: ‑‑ Notification Trigger
    private func handleStoreEntry(storeID: String) {
        guard let store = monitoredStores.first(where: { $0.id == storeID }) else { return }

        // Find low‑stock items
        let lowItems = PantryService.shared.items
            .filter { $0.quantity <= $0.threshold }
            .map(\.name)
        guard !lowItems.isEmpty else { return }

        // Build and post notification
        let content = UNMutableNotificationContent()
        content.title = "You’re near \(store.name)"
        content.body  = "Running low on: \(lowItems.joined(separator: ", "))"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "stockup.reminder.\(store.id)",
            content: content,
            trigger: nil
        )
        notificationCenter.add(request) { error in
            if let error = error {
                print("Notification error:", error)
            }
        }
    }
}

// MARK: ‑‑ CLLocationManagerDelegate
extension LocationReminderManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways:
                print("Location: authorized always")
            case .authorizedWhenInUse:
                print("Location: authorized when in use")
            case .denied, .restricted:
                print("Location: denied/restricted")
            default:
                break
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        handleStoreEntry(storeID: region.identifier)
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.first?.coordinate else { return }
        lastKnownLocation = coord

        // Compute distances and log nearest 5
        let userLoc = CLLocation(latitude: coord.latitude,
                                 longitude: coord.longitude)
        let nearest5 = monitoredStores
            .map { store in
                (store,
                 CLLocation(latitude: store.latitude,
                            longitude: store.longitude)
                   .distance(from: userLoc))
            }
            .sorted { $0.1 < $1.1 }
            .prefix(5)

        print("🔍 Nearest 5 stores to you:")
        for (store, dist) in nearest5 {
            print("• \(store.name) — \(Int(dist))m away")
        }

        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location update failed:", error)
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Monitoring failed for \(region?.identifier ?? "unknown"):", error)
    }
}

// MARK: ‑‑ UNUserNotificationCenterDelegate
extension LocationReminderManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completion:
                                  @escaping (UNNotificationPresentationOptions) -> Void) {
        completion([.banner, .sound])
    }
}
