//
//  UserTargets.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 15/04/2025.
//

import Foundation
import SwiftData

// MARK: - User Targets Model
@Model
final class UserTargets {
    var dailyWaterTarget: Double // in milliliters
    var dailyCalorieTarget: Int
    var dailyStepTarget: Int
    
    init(dailyWaterTarget: Double = 2000, dailyCalorieTarget: Int = 2000, dailyStepTarget: Int = 10000) {
        self.dailyWaterTarget = dailyWaterTarget
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dailyStepTarget = dailyStepTarget
    }
    
    func validateTargets() -> [String] {
        var warnings: [String] = []
        
        if dailyWaterTarget < 500 {
            warnings.append("Water target seems too low. Recommended minimum is 500ml")
        }
        if dailyWaterTarget > 5000 {
            warnings.append("Water target seems too high. Recommended maximum is 5000ml")
        }
        if dailyCalorieTarget < 1200 {
            warnings.append("Calorie target seems too low. Recommended minimum is 1200 calories")
        }
        if dailyCalorieTarget > 4000 {
            warnings.append("Calorie target seems too high. Recommended maximum is 4000 calories")
        }
        if dailyStepTarget < 1000 {
            warnings.append("Step target seems too low. Recommended minimum is 1000 steps")
        }
        
        return warnings
    }
}
