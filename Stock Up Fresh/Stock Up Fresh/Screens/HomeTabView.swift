//
//  GroceryListView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI

struct HomeTabView: View {
    var body: some View {
            TabView {
                GroceryListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Grocery List")
                    }
                
                MyKitchenView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("My Kitchen")
                    }
                
                BarcodeScannerView()
                    .tabItem {
                        Image(systemName: "barcode.viewfinder")
                        Text("Barcode Scanner")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
            
                
               
            }
            .accentColor(Color.appOlive)
        }
    }

    struct HomeTabView_Previews: PreviewProvider {
        static var previews: some View {
            HomeTabView()
        }
    }
    
    








