//
//  StoreRepository.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import Foundation
import FirebaseFirestore
import Combine

/// Manages your “Stores” collection in Firestore and in‑memory list.
final class StoreRepository: ObservableObject {
    static let shared = StoreRepository()
    @Published var stores: [StoreLocation] = []
    
    private let db = Firestore.firestore()
    
    /// Overwrite everything in “Stores” with `newStores`.
    func replaceAll(_ newStores: [StoreLocation]) {
        let batch = db.batch()
        let colRef = db.collection("Stores")
        
        // 1) Delete old docs
        colRef.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch old stores:", error)
                return
            }
            
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            
            // 2) Add each `StoreLocation` as a Firestore document
            newStores.forEach { store in
                let docRef = colRef.document(store.id)
                do {
                    // Leverage Codable conformance
                    try batch.setData(from: store, forDocument: docRef)
                } catch {
                    print("Error writing store \(store.name):", error)
                }
            }
            
            // 3) Commit the batch
            batch.commit { commitError in
                if let commitError = commitError {
                    print("Batch commit failed:", commitError)
                } else {
                    // Update in-memory list on success
                    DispatchQueue.main.async {
                        self.stores = newStores
                    }
                }
            }
        }
    }
    
    /// (Optional) Real-time listener to keep `stores` in sync
    func fetchAll() {
        db.collection("Stores")
          .addSnapshotListener { snapshot, error in
            if let error = error {
              print("Error listening for stores:", error)
              return
            }
            self.stores = snapshot?.documents.compactMap { doc in
              try? doc.data(as: StoreLocation.self)
            } ?? []
        }
    }
}
