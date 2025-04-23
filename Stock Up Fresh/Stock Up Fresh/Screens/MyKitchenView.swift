//
//  MyKitchenView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

struct MyKitchenView: View {
    // MARK: – Dependencies
    @EnvironmentObject private var pantrySvc: PantryService
    @EnvironmentObject private var reminderMgr: LocationReminderManager

    // MARK: – Local State
    @State private var pantryItemsByCategory: [String: [PantryItem]] = [:]
    @State private var showingEditSheet = false
    @State private var selectedItemToEdit: PantryItem?

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBeige.ignoresSafeArea()

                // Pantry List
                List {
                    if pantryItemsByCategory.isEmpty {
                        Text("Loading pantry items...")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(pantryItemsByCategory.keys.sorted(), id: \.self) { category in
                            Section(header:
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.appOlive)
                            ) {
                                ForEach(pantryItemsByCategory[category] ?? []) { item in
                                    Button {
                                        selectedItemToEdit = item
                                        showingEditSheet = true
                                    } label: {
                                        kitchenRow(for: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)

                // Add‑Item Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            selectedItemToEdit = nil
                            showingEditSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appOlive)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        .accessibilityLabel("Add pantry item")
                    }
                }
            }
            .navigationTitle("My Kitchen")
        }
        .sheet(isPresented: $showingEditSheet, onDismiss: fetchPantryItems) {
            AddOrEditPantryItemView(itemToEdit: selectedItemToEdit)
                .environmentObject(pantrySvc)
        }
        .onAppear {
            fetchPantryItems()
            logNearbyStoresForDebug()
        }
    }

    // MARK: – Fetch Pantry Items
    private func fetchPantryItems() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore().collection("users").document(uid).collection("pantry")
            db.getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                var cat: [String: [PantryItem]] = [:]
                for doc in docs {
                    if let item = try? doc.data(as: PantryItem.self) {
                        cat[item.type, default: []].append(item)
                    }
                }
                pantryItemsByCategory = cat
            }
        }

    // MARK: – Row ViewBuilder
    @ViewBuilder
    private func kitchenRow(for item: PantryItem) -> some View {
        let stockLevel = item.stockLevel
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.appOlive)
                Text("Qty: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if stockLevel != .good {
                Text(stockLevel.label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(stockLevel.color.opacity(0.1))
                    .foregroundColor(stockLevel.color)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(stockLevel.color.opacity(0.1))
        .cornerRadius(12)
        .listRowBackground(Color.clear)
    }

    // MARK: – Debug: Log Nearby Stores
    private func logNearbyStoresForDebug() {
        guard let userCoord = reminderMgr.lastKnownLocation else {
            print("⏳ Waiting for user location…")
            return
        }
        let userLoc = CLLocation(latitude: userCoord.latitude,
                                 longitude: userCoord.longitude)

        let distances = reminderMgr.monitoredStores.map { store -> (StoreLocation, CLLocationDistance) in
            let loc = CLLocation(latitude: store.latitude, longitude: store.longitude)
            return (store, loc.distance(from: userLoc))
        }

        let withinMile = distances.filter { $0.1 <= 1609 }
        let nearestFive = distances.sorted { $0.1 < $1.1 }.prefix(5)

        print("🏁 [MyKitchen] Stores within 1 mile (\(withinMile.count)):")
        if withinMile.isEmpty {
            print("   • None found within a mile.")
        } else {
            withinMile.forEach { store, dist in
                print("   • \(store.name) – \(Int(dist)) m away")
            }
        }
    }
}

struct MyKitchenView_Previews: PreviewProvider {
    static var previews: some View {
        MyKitchenView()
            .environmentObject(PantryService.shared)
            .environmentObject(LocationReminderManager.shared)
    }
}
