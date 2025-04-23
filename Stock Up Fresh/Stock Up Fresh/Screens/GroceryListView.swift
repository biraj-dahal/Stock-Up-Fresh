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
    //fetchGroceryItemsFromFirestore

    private func fetchGroceryItemsFromFirestore() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("pantry")
            db.getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                var cat: [String: [PantryItem]] = [:]
                for doc in docs {
                    if let item = try? doc.data(as: PantryItem.self), item.quantity < item.threshold {
                        cat[item.type, default: []].append(item)
                    }
                }
                groceryItemsBySection = cat
            }
        }
}
