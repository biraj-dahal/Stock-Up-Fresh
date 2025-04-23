//
//  StoreRepository.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import Foundation
import FirebaseFirestore

import Combine
import FirebaseAuth

final class StoreRepository: ObservableObject {
    static let shared = StoreRepository()
    @Published var stores: [StoreLocation] = []

    private var db: CollectionReference? {
            guard let uid = Auth.auth().currentUser?.uid else { return nil }
            return Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("stores")
        }
    private var listener: ListenerRegistration?

    private init() {
        fetchAll()
    }

    /// Overwrite everything in “Stores” with `newStores`.
    func replaceAll(_ newStores: [StoreLocation]) {
            guard let db = db else { return }
            let batch = Firestore.firestore().batch()
            db.getDocuments { snap, _ in
                snap?.documents.forEach { batch.deleteDocument($0.reference) }
                newStores.forEach { store in
                    let ref = db.document(store.id)
                    try? batch.setData(from: store, forDocument: ref)
                }
                batch.commit { _ in self.stores = newStores }
            }
        }

        func fetchAll() {
            listener?.remove()
            guard let db = db else { return }
            listener = db.addSnapshotListener { snap, _ in
                self.stores = snap?.documents.compactMap {
                    try? $0.data(as: StoreLocation.self)
                } ?? []
            }
        }
    }
