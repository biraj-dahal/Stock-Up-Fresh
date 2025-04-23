//
//  Stock_Up_FreshApp.swift
//  Stock Up Fresh
//
//  Created by <you> on 4/22/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                       [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Stock_Up_FreshApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @StateObject private var pantrySvc   = PantryService.shared
    @StateObject private var reminderMgr = LocationReminderManager.shared
    @StateObject private var storeRepo = StoreRepository.shared
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if isLoggedIn && Auth.auth().currentUser != nil {
                HomeTabView()
                    .environmentObject(pantrySvc)
                    .environmentObject(reminderMgr)
                    .environmentObject(storeRepo)
                    .onAppear {
                        // 1) Grab one‑shot location
                        reminderMgr.requestOneLocation { coord in
                          GooglePlacesService()
                            .fetchNearbyGroceries(at: coord) { result in
                              switch result {
                              case .failure(let err):
                                print("❌ Places fetch failed:", err)
                              case .success(let groceryStores):
                                // Start geofences directly without DB
                                reminderMgr.startMonitoring(stores: groceryStores)
                              }
                            }
                        }
                    }

            } else {
                AuthFlow()
            }
        }
        .environmentObject(authManager)
    }
}
