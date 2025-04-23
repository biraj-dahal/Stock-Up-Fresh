//
//  AuthManager.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/22/25.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthManager: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("⚠️ Sign-out error: \(error.localizedDescription)")
        }
    }

    deinit {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }
}
