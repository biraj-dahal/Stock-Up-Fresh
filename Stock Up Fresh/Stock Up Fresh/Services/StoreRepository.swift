//
//  StoreRepository.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import Foundation
import FirebaseFirestore

import Combine

final class StoreRepository: ObservableObject {
    static let shared = StoreRepository()
    @Published var stores: [StoreLocation] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {
        fetchAll()
    }

    /// Overwrite everything in “Stores” with `newStores`.
    func replaceAll(_ newStores: [StoreLocation]) {
        let batch = db.batch()
        let colRef = db.collection("Stores")

        colRef.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch old stores:", error)
                return
            }

            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }

            newStores.forEach { store in
                let docRef = colRef.document(store.id)
                do {
                    try batch.setData(from: store, forDocument: docRef)
                } catch {
                    print("Error writing store \(store.name):", error)
                }
            }

            batch.commit { commitError in
                if let commitError = commitError {
                    print("Batch commit failed:", commitError)
                } else {
                    DispatchQueue.main.async {
                        self.stores = newStores
                        print("✅ StoreRepository now has \(newStores.count) stores")
                    }
                }
            }
        }
    }

    /// Listen to Firestore “Stores” collection in real time.
    func fetchAll() {
        listener?.remove()
        listener = db.collection("Stores")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for stores:", error)
                    return
                }
                self.stores = snapshot?.documents.compactMap {
                    try? $0.data(as: StoreLocation.self)
                } ?? []
            }
    }
}
