//
//  GroceryListView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//
import SwiftUI

struct GroceryListView: View {
    // Static sectioned items representing store categories
    let groceryItemsBySection: [String: [String]] = [
        "Produce": ["Apples", "Spinach", "Carrots"],
        "Dairy": ["Milk", "Cheese", "Yogurt"],
        "Bakery": ["Bread", "Bagels"],
        "Meat & Seafood": ["Chicken Breast", "Salmon"],
        "Pantry": ["Rice", "Pasta", "Canned Beans"]
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                if groceryItemsBySection.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.appOlive)
                        Text("Your grocery list is empty!")
                            .font(.title3)
                            .foregroundColor(.appOlive)
                        Text("Tap the '+' button to start adding items.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                } else {
                    List {
                        ForEach(groceryItemsBySection.keys.sorted(), id: \.self) { section in
                            Section(header: Text(section)
                                .font(.headline)
                                .foregroundColor(.appOlive)) {
                                    ForEach(groceryItemsBySection[section]!, id: \.self) { item in
                                        Text(item)
                                            .foregroundColor(.appOlive)
                                            .padding(8)
                                            .background(Color.appBeige)
                                            .cornerRadius(8)
                                    }
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Add new item tapped")
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
                        .accessibilityLabel("Add grocery item")
                    }
                }
            }
            .navigationTitle("Grocery List")
            .background(Color.appBeige.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    GroceryListView()
}
