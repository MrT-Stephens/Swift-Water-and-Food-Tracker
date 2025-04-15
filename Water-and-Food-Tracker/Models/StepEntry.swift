//
//  StepEntry.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 15/04/2025.
//

import Foundation
import SwiftData

// MARK: - Step Entry Model
@Model
final class StepEntry {
    var date: Date
    var count: Int
    
    init(date: Date, count: Int) {
        self.date = date
        self.count = count
    }
}
