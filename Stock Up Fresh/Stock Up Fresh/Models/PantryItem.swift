//
//  PantryItem.swift
//  Stock Up Fresh
//
//  Created by Robel Melaku on 4/10/25.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct PantryItem: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var quantity: Int
    var threshold: Int
    var type: String

    var stockLevel: StockLevel {
        if quantity == 0 { return .empty }
        else if quantity < threshold { return .low }
        else { return .good }
    }
}

enum StockLevel {
    case empty, low, good

    var label: String {
        switch self {
        case .empty: return "Out of Stock"
        case .low: return "Low Stock"
        case .good: return ""
        }
    }

    var color: Color {
        switch self {
        case .empty: return .red
        case .low: return .orange
        case .good: return .green
        }
    }
}
