//
//  WaterEntry.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 15/04/2025.
//

import Foundation
import SwiftData

// MARK: - Water Entry Model
@Model
final class WaterEntry {
    var id: UUID
    var amount: Double // in milliliters
    var timestamp: Date
    
    init(id: UUID = UUID(), amount: Double) {
        self.id = id
        self.amount = amount
        self.timestamp = Date()
    }
}
