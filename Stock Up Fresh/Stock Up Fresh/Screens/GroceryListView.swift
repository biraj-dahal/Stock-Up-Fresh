//
//  GroceryListView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI

struct GroceryListView: View {
    @State private var groceryItems: [String] = [
        "Apples",
        "Milk"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                if groceryItems.isEmpty {
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
                        ForEach(groceryItems, id: \.self) { item in
                            Text(item)
                                .foregroundColor(.appOlive)
                                .padding(8)
                                .background(Color.appBeige)
                                .cornerRadius(8)
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

