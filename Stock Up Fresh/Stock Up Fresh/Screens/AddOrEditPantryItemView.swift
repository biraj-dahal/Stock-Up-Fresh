//
//  AddOrEditPantryItemView.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/21/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("pantry")
        let id = itemToEdit?.id ?? UUID().uuidString
        let item = PantryItem(id: id, name: name, quantity: quantity, threshold: threshold, type: type)
        try? db.document(id).setData(from: item)
        dismiss()
    }
    
    private func deleteItem() {
        guard let uid = Auth.auth().currentUser?.uid,
              let id = itemToEdit?.id else { return }
        let db = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("pantry")
        db.document(id).delete()
        dismiss()
    }
}
