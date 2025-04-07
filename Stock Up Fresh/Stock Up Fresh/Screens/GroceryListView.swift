//
//  GroceryListView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI

struct GroceryListView: View {
    // Sample grocery items
    // Only to have an idea of how it will look later...
    @State private var groceryItems: [String] = [
        "Apples",
        "Bananas",
        "Carrots",
        "Milk",
        "Bread",
        "Eggs"
    ]
    var body: some View {
        NavigationView {
            List {
                ForEach(groceryItems, id: \.self) { item in
                    Text(item)
                        .foregroundColor(Color.appOlive)
                        .padding(8)
                        .background(Color.appBeige)
                        .cornerRadius(8)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Grocery List")
            .scrollContentBackground(.hidden)
            .background(Color.appBeige.edgesIgnoringSafeArea(.all))
        }
            
    }
}

#Preview {
    GroceryListView()
}
