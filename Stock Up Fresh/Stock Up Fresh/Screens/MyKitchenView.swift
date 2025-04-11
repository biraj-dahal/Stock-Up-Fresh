//
//  MyKitchenView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//
import SwiftUI

struct MyKitchenView: View {
    let categorizedPantryItems: [String: [PantryItem]] = [
        "Produce": [
            PantryItem(name: "Spinach", quantity: 0, threshold: 1),
            PantryItem(name: "Carrots", quantity: 2, threshold: 3),
            PantryItem(name: "Bell Peppers", quantity: 5, threshold: 2),
            PantryItem(name: "Avocados", quantity: 1, threshold: 2)
        ],
        "Dairy": [
            PantryItem(name: "Milk", quantity: 1, threshold: 2),
            PantryItem(name: "Yogurt", quantity: 3, threshold: 2),
            PantryItem(name: "Cheddar Cheese", quantity: 0, threshold: 1),
            PantryItem(name: "Butter", quantity: 2, threshold: 1)
        ],
        "Meat & Seafood": [
            PantryItem(name: "Chicken Breast", quantity: 2, threshold: 2),
            PantryItem(name: "Ground Beef", quantity: 0, threshold: 1),
            PantryItem(name: "Salmon Fillets", quantity: 1, threshold: 1),
            PantryItem(name: "Bacon", quantity: 1, threshold: 1)
        ],
        "Bakery": [
            PantryItem(name: "Bread", quantity: 1, threshold: 2),
            PantryItem(name: "Bagels", quantity: 3, threshold: 2),
            PantryItem(name: "Tortillas", quantity: 0, threshold: 1)
        ],
        "Pantry": [
            PantryItem(name: "Pasta", quantity: 3, threshold: 2),
            PantryItem(name: "Rice", quantity: 0, threshold: 1),
            PantryItem(name: "Canned Tomatoes", quantity: 4, threshold: 3),
            PantryItem(name: "Olive Oil", quantity: 1, threshold: 1),
            PantryItem(name: "Peanut Butter", quantity: 1, threshold: 1)
        ]
    ]


    var body: some View {
        NavigationView {
            ZStack {
                Color.appBeige.ignoresSafeArea()

                List {
                    ForEach(categorizedPantryItems.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)
                            .font(.headline)
                            .foregroundColor(.appOlive)) {
                                ForEach(categorizedPantryItems[category]!) { item in
                                    kitchenRow(for: item)
                                }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Kitchen")
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

#Preview {
    MyKitchenView()
}
