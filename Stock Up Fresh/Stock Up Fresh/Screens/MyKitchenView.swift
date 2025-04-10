//
//  MyKitchenView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI

struct PantryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let threshold: Int
    
    var isLow: Bool {
        quantity <= threshold
    }
}

struct MyKitchenView: View {
    // Sample data (replace with network or DB source)
    let pantryItems: [PantryItem] = [
        PantryItem(name: "Milk", quantity: 1, threshold: 2),
        PantryItem(name: "Eggs", quantity: 12, threshold: 6),
        PantryItem(name: "Spinach", quantity: 0, threshold: 1),
        PantryItem(name: "Pasta", quantity: 3, threshold: 2)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBeige.ignoresSafeArea()
                
                List {
                    ForEach(pantryItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.appOlive)
                                
                                Text("Qty: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if item.isLow {
                                Text("Low")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Kitchen")
        }
    }
}

#Preview {
    MyKitchenView()
}
