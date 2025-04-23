//
//  PantryService.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 2025-04-21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

/// Manages real-time CRUD operations for PantryItem objects in Firestore.
final class PantryService: ObservableObject {
    static let shared = PantryService()
    
    @Published var items: [PantryItem] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {
        fetchPantryItems()
    }
    
    deinit {
        listener?.remove()
    }
    
    /// Begins listening to the 'PantryItems' collection for live updates.
    func fetchPantryItems() {
            listener?.remove()
            guard let uid = Auth.auth().currentUser?.uid else { return }
            listener = Firestore.firestore()
                .collection("users").document(uid).collection("pantry")
                .order(by: "name")
                .addSnapshotListener { snap, _ in
                    self.items = snap?.documents.compactMap { try? $0.data(as: PantryItem.self) } ?? []
                }
        }

        func addItem(_ item: PantryItem) {
            guard let uid = Auth.auth().currentUser?.uid,
                  let id = item.id else { return }
            try? Firestore.firestore().collection("users").document(uid).collection("pantry").document(id).setData(from: item)
        }

        func updateItem(_ item: PantryItem) {
            addItem(item)
        }

    // PantryService.swift

    func deleteItem(_ item: PantryItem) {
        guard let uid = Auth.auth().currentUser?.uid,
              let id = item.id else { return }
        let db = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("pantry")
        db.document(id).delete { error in
            if let error = error {
                print("❌ Error deleting pantry item: \(error)")
            }
        }
    }

}
