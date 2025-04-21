//
//  Stock_Up_FreshApp.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/5/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn && Auth.auth().currentUser != nil {
                HomeTabView()
                
            } else {
                AuthFlow()
            }
        }
    }
}
