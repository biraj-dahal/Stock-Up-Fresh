//
//  Stock_Up_FreshApp.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/5/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Stock_Up_FreshApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @StateObject private var reminderMgr = LocationReminderManager.shared
    @StateObject private var pantrySvc   = PantryService.shared
    @StateObject private var storeRepo   = StoreRepository.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            if isLoggedIn && Auth.auth().currentUser != nil {
                HomeTabView()
                    .environmentObject(pantrySvc)
                    .environmentObject(storeRepo)
                    .environmentObject(reminderMgr)
                    .onAppear {
                            // once stores are loaded from your repo:
                            storeRepo.$stores
                              .sink { stores in
                                reminderMgr.startMonitoring(stores: stores)
                              }
                              .store(in: &reminderMgr.cancellables)
                          }
                
            } else {
                AuthFlow()
            }
        }
        
    }
}
