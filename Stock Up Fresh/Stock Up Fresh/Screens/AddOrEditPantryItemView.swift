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
}
