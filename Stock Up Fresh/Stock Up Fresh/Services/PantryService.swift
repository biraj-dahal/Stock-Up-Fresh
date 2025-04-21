//
//  PantryService.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 2025-04-21.
//

import Foundation
import FirebaseFirestore
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
        listener = db.collection("PantryItems")
            .order(by: "name", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching pantry items:", error)
                    return
                }
                self.items = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PantryItem.self)
                } ?? []
            }
    }
    
    /// Adds a new PantryItem to Firestore.
    func addItem(_ item: PantryItem, completion: ((Error?) -> Void)? = nil) {
        do {
            _ = try db.collection("PantryItems").addDocument(from: item) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    /// Updates an existing PantryItem in Firestore.
    func updateItem(_ item: PantryItem, completion: ((Error?) -> Void)? = nil) {
        guard let id = item.id else {
            completion?(NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Item has no ID"]
            ))
            return
        }
        do {
            try db.collection("PantryItems")
                .document(id)
                .setData(from: item, merge: true) { error in
                    completion?(error)
                }
        } catch {
            completion?(error)
        }
    }
    
    /// Deletes a PantryItem from Firestore.
    func deleteItem(_ item: PantryItem, completion: ((Error?) -> Void)? = nil) {
        guard let id = item.id else {
            completion?(NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Item has no ID"]
            ))
            return
        }
        db.collection("PantryItems")
          .document(id)
          .delete { error in
            completion?(error)
          }
    }
}
