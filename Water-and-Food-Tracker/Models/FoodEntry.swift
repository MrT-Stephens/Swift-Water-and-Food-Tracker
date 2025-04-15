//
//  FoodEntry.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 15/04/2025.
//

import Foundation
import SwiftData

// MARK: - Food Entry Model
@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var category: String
    var timestamp: Date
    var calories: Int
    var notes: String?
    
    init(id: UUID = UUID(), name: String, category: String, calories: Int, notes: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.timestamp = Date()
        self.calories = calories
        self.notes = notes
    }
}
