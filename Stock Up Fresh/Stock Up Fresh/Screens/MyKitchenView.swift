//
//  MyKitchenView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI
import FirebaseFirestore

struct MyKitchenView: View {
    @State private var pantryItemsByCategory: [String: [PantryItem]] = [:]
    @State private var showingEditSheet = false
    @State private var selectedItemToEdit: PantryItem?

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBeige.ignoresSafeArea()

                List {
                    if pantryItemsByCategory.isEmpty {
                        Text("Loading pantry items...")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(pantryItemsByCategory.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category)
                                .font(.headline)
                                .foregroundColor(.appOlive)) {
                                    ForEach(pantryItemsByCategory[category] ?? []) { item in
                                        Button(action: {
                                            selectedItemToEdit = item
                                            showingEditSheet = true
                                        }) {
                                            kitchenRow(for: item)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedItemToEdit = nil // new item
                            showingEditSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
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
        }
        .onAppear(perform: fetchPantryItems)
    }

    private func fetchPantryItems() {
        let db = Firestore.firestore()
        db.collection("pantry").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching pantry items: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            var categorized: [String: [PantryItem]] = [:]

            for doc in documents {
                do {
                    let item = try doc.data(as: PantryItem.self)
                    categorized[item.type, default: []].append(item)
                } catch {
                    print("⚠️ Could not decode item: \(error)")
                }
            }

            pantryItemsByCategory = categorized
        }
    }

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
}
