//
//  AddOrEditPantryItemView.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import SwiftUI
import FirebaseFirestore

struct AddOrEditPantryItemView: View {
    @Environment(\.dismiss) var dismiss
    var itemToEdit: PantryItem?

    @State private var name: String = ""
    @State private var quantity: Int = 0
    @State private var threshold: Int = 1
    @State private var type: String = ""
    @State private var showingDeleteAlert = false

    private let types = ["Produce", "Dairy", "Meat & Seafood", "Bakery", "Essential"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...100)
                    Stepper("Threshold: \(threshold)", value: $threshold, in: 1...50)
                    Picker("Category", selection: $type) {
                        ForEach(types, id: \.self) { category in
                            Text(category)
                        }
                    }
                }
                if itemToEdit != nil {
                                    Section {
                                        Button(role: .destructive) {
                                            showingDeleteAlert = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "trash.fill")
                                                Text("Delete Item")
                                            }
                                        }
                                    }
                                }
            }
            .navigationTitle(itemToEdit == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let item = itemToEdit {
                    name = item.name
                    quantity = item.quantity
                    threshold = item.threshold
                    type = item.type
                }
            }
            .alert("Delete Item?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveItem() {
        let db = Firestore.firestore()
        let pantryItem = PantryItem(
            id: itemToEdit?.id ?? UUID().uuidString,
            name: name,
            quantity: quantity,
            threshold: threshold,
            type: type
        )

        do {
            try db.collection("pantry").document(pantryItem.id!).setData(from: pantryItem)
            dismiss()
        } catch {
            print("❌ Failed to save pantry item: \(error)")
        }
    }
    
    private func deleteItem() {
        guard let item = itemToEdit?.id else { return }
            let db = Firestore.firestore()
        db.collection("pantry").document(item).delete { error in
                if let error = error {
                    print("❌ Error deleting pantry item: \(error)")
                } else {
                    dismiss()
                }
            }
        }
}
