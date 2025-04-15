import Foundation
import SwiftData
import WidgetKit

// MARK: - Data Manager
@Observable
class DataManager {
    var modelContext: ModelContext
    var stepCount: Int = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    func updateStepCount(_ count: Int) {
        stepCount = count
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Create or update step entry for today
        let descriptor = FetchDescriptor<StepEntry>(
            predicate: #Predicate<StepEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        
        if let existingEntry = try? modelContext.fetch(descriptor).first {
            existingEntry.count = count
        } else {
            let newEntry = StepEntry(date: today, count: count)
            modelContext.insert(newEntry)
        }
        
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getDailyFoodEntries() -> [FoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getDailyWaterEntries() -> [WaterEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate<WaterEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getTotalWaterConsumption() -> Double {
        return getDailyWaterEntries().reduce(0) { $0 + $1.amount }
    }
    
    func getTotalCalories() -> Int {
        return getDailyFoodEntries().reduce(0) { $0 + $1.calories }
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        // Check if we need to initialize with default data
        let descriptor = FetchDescriptor<UserTargets>()
        if (try? modelContext.fetch(descriptor).first) == nil {
            // Initialize with default targets
            let defaultTargets = UserTargets()
            modelContext.insert(defaultTargets)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
} 
