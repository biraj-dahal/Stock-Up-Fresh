//
//  PantryItem.swift
//  Stock Up Fresh
//
//  Created by Robel Melaku on 4/10/25.
//

import Foundation

struct PantryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let threshold: Int
    
    var isLow: Bool {
        quantity <= threshold
    }
}
