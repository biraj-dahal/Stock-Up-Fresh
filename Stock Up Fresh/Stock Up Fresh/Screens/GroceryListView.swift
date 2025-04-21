import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct GroceryListView: View {
    @State private var groceryItemsBySection: [String: [PantryItem]] = [:]

    var body: some View {
        NavigationView {
            ZStack {
                if groceryItemsBySection.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.appOlive)
                        Text("You're all stocked up!")
                            .font(.title3)
                            .foregroundColor(.appOlive)
                        Text("No items need to be purchased.")
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
                                    ForEach(groceryItemsBySection[section] ?? []) { item in
                                        Text(item.name)
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

            }
            .navigationTitle("Grocery List")
            .background(Color.appBeige.edgesIgnoringSafeArea(.all))
        }
        .onAppear(perform: fetchGroceryItemsFromFirestore)
    }

    private func fetchGroceryItemsFromFirestore() {
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
                    if item.quantity < item.threshold {
                        categorized[item.type, default: []].append(item)
                    }
                } catch {
                    print("⚠️ Could not decode item: \(error)")
                }
            }

            groceryItemsBySection = categorized
        }
    }
}
