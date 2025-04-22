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

/// Manages one‑shot device location requests and in‑memory geofence monitoring.
public final class LocationReminderManager: NSObject, ObservableObject {
    public static let shared = LocationReminderManager()

    // MARK: - Published properties (must update on main thread)
    @Published public private(set) var monitoredStores: [StoreLocation] = []
    @Published public private(set) var lastKnownLocation: CLLocationCoordinate2D?

    // MARK: - Internals
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    public var cancellables = Set<AnyCancellable>()

    /// Temporary callback for a one‑shot location fetch.
    private var oneShotHandler: ((CLLocationCoordinate2D) -> Void)?

    // MARK: - Initializer
    private override init() {
        super.init()
        locationManager.delegate = self
        notificationCenter.delegate = self

        // Always‑on location for geofences
        locationManager.requestAlwaysAuthorization()
        // Allow local notifications
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Geofence Monitoring

    /// Start geofencing the given stores (100m radius each).
    /// This method safely publishes `monitoredStores` on the main thread.
    public func startMonitoring(stores: [StoreLocation]) {
        // Stop any existing regions
        locationManager.monitoredRegions.forEach {
            locationManager.stopMonitoring(for: $0)
        }

        // Publish new stores on main queue
        DispatchQueue.main.async {
            self.monitoredStores = stores
        }

        // Begin monitoring each store region
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

    // MARK: - One‑Shot Location

    /// Request exactly one location fix, invoking `handler` when received.
    public func requestOneLocation(_ handler: @escaping (CLLocationCoordinate2D) -> Void) {
        oneShotHandler = handler
        locationManager.requestLocation()
    }

    // MARK: - Geofence Entry

    /// Fires a local notification for low‑stock items when entering a store geofence.
    private func handleStoreEntry(storeID: String) {
        guard let store = monitoredStores.first(where: { $0.id == storeID }) else {
            return
        }
        let lowItems = PantryService.shared.items
            .filter { $0.quantity <= $0.threshold }
            .map(\.name)

        guard !lowItems.isEmpty else { return }

        let content = UNMutableNotificationContent()
        content.title = "You’re near \(store.name)"
        content.body = "Running low on: \(lowItems.joined(separator: ", "))"
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

// MARK: – CLLocationManagerDelegate

extension LocationReminderManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager,
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

    public func locationManager(_ manager: CLLocationManager,
                                didEnterRegion region: CLRegion) {
        print("🌐 Entered geofence for store ID:", region.identifier)
        handleStoreEntry(storeID: region.identifier)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.first?.coordinate else { return }

        // Publish on main thread
        DispatchQueue.main.async {
            self.lastKnownLocation = coord
        }

        // Fire one‑shot callback if present
        if let cb = oneShotHandler {
            DispatchQueue.main.async { cb(coord) }
            oneShotHandler = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        print("❌ Location update failed:", error.localizedDescription)
    }

    public func locationManager(_ manager: CLLocationManager,
                                monitoringDidFailFor region: CLRegion?,
                                withError error: Error) {
        print("❌ Monitoring failed for region \(region?.identifier ?? "unknown"):", error.localizedDescription)
    }
}

// MARK: – UNUserNotificationCenterDelegate

extension LocationReminderManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completion:
          @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completion([.banner, .sound])
    }
}
