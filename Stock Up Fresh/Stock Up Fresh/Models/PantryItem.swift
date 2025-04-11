//
//  PantryItem.swift
//  Stock Up Fresh
//
//  Created by Robel Melaku on 4/10/25.
//
import Foundation
import SwiftUI

struct PantryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let threshold: Int

    var isLow: Bool {
        quantity < threshold
    }

    var stockLevel: StockLevel {
        if quantity == 0 {
            return .empty
        } else if quantity < threshold {
            return .low
        } else {
            return .good
        }
    }
}

enum StockLevel {
    case empty
    case low
    case good

    var color: Color {
        switch self {
        case .empty:
            return .red
        case .low:
            return .yellow
        case .good:
            return .green
        }
    }

    var label: String {
        switch self {
        case .empty:
            return "Empty"
        case .low:
            return "Low"
        case .good:
            return "Stocked"
        }
    }
}
