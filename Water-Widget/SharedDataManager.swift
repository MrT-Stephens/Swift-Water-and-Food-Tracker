import Foundation

// MARK: - Shared Data Manager
class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let userDefaults: UserDefaults?
    private let appGroupIdentifier = "group.com.thomasstephens.waterandfoodtracker"
    
    private let foodEntriesKey = "foodEntries"
    private let waterEntriesKey = "waterEntries"
    private let userTargetsKey = "userTargets"
    
    private init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - Data Access Methods
    
    func getTodayWaterIntake() -> Double {
        guard let data = userDefaults?.data(forKey: waterEntriesKey),
              let waterEntries = try? JSONDecoder().decode([WaterEntry].self, from: data) else {
            return 0
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return waterEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getTodayFoodIntake() -> Double {
        guard let data = userDefaults?.data(forKey: foodEntriesKey),
              let foodEntries = try? JSONDecoder().decode([FoodEntry].self, from: data) else {
            return 0
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return Double(foodEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories })
    }
    
    func getUserTargets() -> UserTargets? {
        guard let data = userDefaults?.data(forKey: userTargetsKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(UserTargets.self, from: data)
    }
}

// MARK: - Model Definitions
// These need to match the models in your main app
struct WaterEntry: Codable {
    var id: UUID
    var amount: Double
    var timestamp: Date
}

struct FoodEntry: Codable {
    var id: UUID
    var name: String
    var category: String
    var timestamp: Date
    var calories: Int
    var notes: String?
}

struct UserTargets: Codable {
    var dailyWaterTarget: Double
    var dailyCalorieTarget: Int
    var dailyStepTarget: Int
} 