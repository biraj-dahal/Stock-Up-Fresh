//
//  HomeTabView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI
import CoreLocation

struct HomeTabView: View {
    @EnvironmentObject var storeRepo: StoreRepository
    @EnvironmentObject var reminderMgr: LocationReminderManager

    var body: some View {
        TabView {
            GroceryListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Grocery List")
                }
            MyKitchenView()
                .tabItem {
                    Image(systemName: "house")
                    Text("My Kitchen")
                }
            BarcodeScannerView()
                .tabItem {
                    Image(systemName: "barcode.viewfinder")
                    Text("Scan")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onReceive(storeRepo.$stores) { stores in
            // 1) Ensure we have a user location
            guard let userCoord = reminderMgr.lastKnownLocation else {
                print("⏳ Waiting for user location…")
                return
            }
            let userLoc = CLLocation(latitude: userCoord.latitude,
                                     longitude: userCoord.longitude)

            // 2) Compute distances
            let distances = stores.map { store -> (StoreLocation, CLLocationDistance) in
                let storeLoc = CLLocation(latitude: store.latitude,
                                          longitude: store.longitude)
                return (store, storeLoc.distance(from: userLoc))
            }

            // 3) Filter under 1 mile (1,609 m)
            let withinMile = distances.filter { $0.1 <= 1609 }

            // 4) Sort & pick nearest 5
            let nearestFive = distances.sorted { $0.1 < $1.1 }.prefix(5)

            // 5) Print results
            print("🏁 Stores within 1 mile (\(withinMile.count)):")
            if withinMile.isEmpty {
                print("   • None found within a mile.")
            } else {
                withinMile.forEach { store, dist in
                    print("   • \(store.name) – \(Int(dist)) m away")
                }
            }

            print("🔍 5 Nearest Stores:")
            nearestFive.forEach { store, dist in
                print("   • \(store.name) – \(Int(dist)) m away")
            }
        }
    }
}


struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(PantryService.shared)
            .environmentObject(StoreRepository.shared)
            .environmentObject(LocationReminderManager.shared)
    }
}
