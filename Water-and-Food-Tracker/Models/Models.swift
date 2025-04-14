import Foundation

// MARK: - Food Entry Model
struct FoodEntry: Identifiable, Codable {
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

// MARK: - Water Entry Model
struct WaterEntry: Identifiable, Codable {
    var id: UUID
    var amount: Double // in milliliters
    var timestamp: Date
    
    init(id: UUID = UUID(), amount: Double) {
        self.id = id
        self.amount = amount
        self.timestamp = Date()
    }
}

// MARK: - User Targets Model
struct UserTargets: Codable {
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

// MARK: - Data Manager
class DataManager: ObservableObject {
    @Published var foodEntries: [FoodEntry] = []
    @Published var waterEntries: [WaterEntry] = []
    @Published var userTargets: UserTargets = UserTargets()
    @Published var stepCount: Int = 0
    @Published var stepEntries: [Date: Int] = [:]
    
    private let foodEntriesKey = "foodEntries"
    private let waterEntriesKey = "waterEntries"
    private let userTargetsKey = "userTargets"
    private let stepEntriesKey = "stepEntries"
    
    init() {
        loadData()
        
        // Uncomment the line below to reset all data and initialize with default data
        // resetAndInitializeWithDefaultData()
    }
    
    // Function to clear all data without initializing with default data
    func resetAllData() {
        // Clear all data
        foodEntries = []
        waterEntries = []
        userTargets = UserTargets()
        stepCount = 0
        stepEntries = [:]
        
        // Save empty data to clear UserDefaults
        saveData()
    }
    
    // Function to clear all data and initialize with default data
    func resetAndInitializeWithDefaultData(extensive: Bool = false) {
        // Clear all data
        resetAllData()
        
        // Initialize with default data
        let calendar = Calendar.current
        let today = Date()
        
        // Determine how many days of data to generate
        let daysToGenerate = extensive ? 365 : 7 // Full year when extensive
        
        // Add water entries
        for dayOffset in 0..<daysToGenerate {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            
            // Generate 3-8 water entries per day when extensive, 1-3 otherwise
            let entriesCount = extensive ? Int.random(in: 3...8) : Int.random(in: 1...3)
            
            // Daily water target is 2000ml, generate entries that sum close to this
            let targetWater = 2000.0
            var remainingWater = targetWater * Double.random(in: 0.7...1.3) // Vary daily total by ±30%
            
            for i in 0..<entriesCount {
                var randomAmount: Double
                if i == entriesCount - 1 {
                    // Last entry: use remaining amount
                    randomAmount = remainingWater
                } else {
                    // Random portion of remaining amount
                    randomAmount = remainingWater * Double.random(in: 0.1...0.5)
                }
                remainingWater -= randomAmount
                
                var entry = WaterEntry(amount: max(50, randomAmount)) // Minimum 50ml per entry
                
                // Set a random time during the day
                let randomHour = Int.random(in: 8...22) // Between 8 AM and 10 PM
                let randomMinute = Int.random(in: 0...59)
                entry.timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
                
                waterEntries.append(entry)
            }
        }
        
        // Add food entries
        let foodCategories = ["Breakfast", "Lunch", "Dinner", "Snack"]
        let mealTimes = [
            "Breakfast": 7...9,
            "Lunch": 11...13,
            "Dinner": 18...20,
            "Snack": 10...21
        ]
        
        let foodNames = [
            "Breakfast": [
                "Oatmeal": 150...300,
                "Toast with Avocado": 220...350,
                "Eggs Benedict": 350...500,
                "Yogurt with Granola": 200...400,
                "Pancakes": 300...600,
                "Fruit Smoothie": 150...300,
                "Breakfast Burrito": 400...600
            ],
            "Lunch": [
                "Sandwich": 300...500,
                "Salad": 200...400,
                "Soup": 150...300,
                "Pasta": 400...600,
                "Rice Bowl": 350...550,
                "Burger": 500...800,
                "Wrap": 300...500
            ],
            "Dinner": [
                "Grilled Chicken": 300...500,
                "Fish": 200...400,
                "Steak": 400...700,
                "Stir Fry": 350...550,
                "Pizza": 500...800,
                "Pasta": 400...600,
                "Curry": 450...650
            ],
            "Snack": [
                "Apple": 50...100,
                "Banana": 80...120,
                "Nuts": 150...250,
                "Chips": 150...300,
                "Protein Bar": 180...250,
                "Yogurt": 100...200,
                "Cookie": 150...250
            ]
        ]
        
        for dayOffset in 0..<daysToGenerate {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            
            // Add entries for each meal category
            for category in foodCategories {
                // Skip some meals randomly (but less often when extensive)
                let skipProbability = extensive ? 0.1 : 0.3
                if Double.random(in: 0...1) < skipProbability {
                    continue
                }
                
                // Get random food item for this category
                let categoryFoods = foodNames[category]!
                let foodItem = categoryFoods.randomElement()!
                let name = foodItem.key
                let calorieRange = foodItem.value
                let calories = Int.random(in: calorieRange)
                
                var entry = FoodEntry(name: name, category: category, calories: calories)
                
                // Set appropriate time for the meal
                let timeRange = mealTimes[category]!
                let randomHour = Int.random(in: timeRange)
                let randomMinute = Int.random(in: 0...59)
                entry.timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
                
                foodEntries.append(entry)
            }
            
            // Add random extra snacks (more when extensive)
            let maxExtraSnacks = extensive ? 3 : 1
            let extraSnacks = Int.random(in: 0...maxExtraSnacks)
            for _ in 0..<extraSnacks {
                let snackFoods = foodNames["Snack"]!
                let foodItem = snackFoods.randomElement()!
                let name = foodItem.key
                let calorieRange = foodItem.value
                let calories = Int.random(in: calorieRange)
                
                var entry = FoodEntry(name: name, category: "Snack", calories: calories)
                
                // Random time for snacks
                let randomHour = Int.random(in: mealTimes["Snack"]!)
                let randomMinute = Int.random(in: 0...59)
                entry.timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
                
                foodEntries.append(entry)
            }
        }
        
        // Set default targets
        userTargets = UserTargets(
            dailyWaterTarget: 2000,
            dailyCalorieTarget: 2000,
            dailyStepTarget: 10000
        )
        
        // Add simulated step data
        for dayOffset in 0..<daysToGenerate {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let normalizedDate = calendar.startOfDay(for: date)
            
            // Generate a random step count between 2000 and 15000
            // Higher counts on weekdays, lower on weekends
            let isWeekend = calendar.isDateInWeekend(normalizedDate)
            let baseSteps = isWeekend ? 2000 : 8000
            
            // Add some randomness to make it more realistic
            let randomSteps = Int.random(in: 0...7000)
            let steps = baseSteps + randomSteps
            
            stepEntries[normalizedDate] = steps
            
            // If this is today, also update the current step count
            if dayOffset == 0 {
                stepCount = steps
            }
        }
        
        // Save the initialized data
        saveData()
    }
    
    func addFoodEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
        saveData()
    }
    
    func addWaterEntry(_ entry: WaterEntry) {
        waterEntries.append(entry)
        saveData()
    }
    
    func updateUserTargets(_ targets: UserTargets) {
        userTargets = targets
        saveData()
    }
    
    func updateStepCount(_ count: Int) {
        stepCount = count
        
        // Also update the stepEntries dictionary with the current date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        stepEntries[today] = count
        
        // Save the updated data
        saveData()
    }
    
    func getDailyFoodEntries() -> [FoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return foodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }
    
    func getDailyWaterEntries() -> [WaterEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return waterEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }
    
    func getTotalWaterConsumption() -> Double {
        return getDailyWaterEntries().reduce(0) { $0 + $1.amount }
    }
    
    func getTotalCalories() -> Int {
        return getDailyFoodEntries().reduce(0) { $0 + $1.calories }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(foodEntries) {
            UserDefaults.standard.set(encoded, forKey: foodEntriesKey)
        }
        if let encoded = try? JSONEncoder().encode(waterEntries) {
            UserDefaults.standard.set(encoded, forKey: waterEntriesKey)
        }
        if let encoded = try? JSONEncoder().encode(userTargets) {
            UserDefaults.standard.set(encoded, forKey: userTargetsKey)
        }
        if let encoded = try? JSONEncoder().encode(stepEntries) {
            UserDefaults.standard.set(encoded, forKey: stepEntriesKey)
        }
    }
    
    private func loadData() {
        if let foodData = UserDefaults.standard.data(forKey: foodEntriesKey),
           let decodedFood = try? JSONDecoder().decode([FoodEntry].self, from: foodData) {
            foodEntries = decodedFood
        }
        
        if let waterData = UserDefaults.standard.data(forKey: waterEntriesKey),
           let decodedWater = try? JSONDecoder().decode([WaterEntry].self, from: waterData) {
            waterEntries = decodedWater
        }
        
        if let targetsData = UserDefaults.standard.data(forKey: userTargetsKey),
           let decodedTargets = try? JSONDecoder().decode(UserTargets.self, from: targetsData) {
            userTargets = decodedTargets
        }
        
        if let stepData = UserDefaults.standard.data(forKey: stepEntriesKey),
           let decodedSteps = try? JSONDecoder().decode([Date: Int].self, from: stepData) {
            stepEntries = decodedSteps
        }
    }
} 
