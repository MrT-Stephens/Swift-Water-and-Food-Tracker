import SwiftUI
import SwiftData
import WidgetKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var waterTarget = ""
    @State private var calorieTarget = ""
    @State private var stepTarget = ""
    @State private var showingTargetWarnings = false
    @State private var targetWarnings: [String] = []
    @State private var showingResetConfirmation = false
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    
    @Query private var userTargets: [UserTargets]
    
    private var currentTargets: UserTargets {
        userTargets.first ?? UserTargets()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Targets")) {
                    HStack {
                        Text("Water Target")
                        Spacer()
                        TextField("ml", text: $waterTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("ml")
                    }
                    
                    HStack {
                        Text("Calorie Target")
                        Spacer()
                        TextField("kcal", text: $calorieTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                    }
                    
                    HStack {
                        Text("Step Target")
                        Spacer()
                        TextField("steps", text: $stepTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("steps")
                    }
                    
                    Button("Save Targets") {
                        saveTargets()
                    }
                    .disabled(waterTarget.isEmpty && calorieTarget.isEmpty && stepTarget.isEmpty)
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive, action: {
                        showingResetConfirmation = true
                    }) {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    if !notificationManager.isAuthorized {
                        Button("Enable Notifications") {
                            notificationManager.requestAuthorization()
                        }
                    } else {
                        Toggle("Water Reminders", isOn: $notificationManager.isWaterReminderEnabled)
                        
                        if notificationManager.isWaterReminderEnabled {
                            DatePicker("Water Reminder Time", selection: $notificationManager.waterReminderTime, displayedComponents: .hourAndMinute)
                        }
                        
                        Toggle("Food Reminders", isOn: $notificationManager.isFoodReminderEnabled)
                        
                        if notificationManager.isFoodReminderEnabled {
                            DatePicker("Food Reminder Time", selection: $notificationManager.foodReminderTime, displayedComponents: .hourAndMinute)
                        }
                        
                        Toggle("Daily Progress Updates", isOn: $notificationManager.isProgressNotificationEnabled)
                        
                        if notificationManager.isProgressNotificationEnabled {
                            DatePicker("Progress Update Time", selection: $notificationManager.progressNotificationTime, displayedComponents: .hourAndMinute)
                        }
                    }
                }
                
                Section(header: Text("Debug")) {
                    Toggle("Enable Debug Mode", isOn: $debugModeEnabled)
                    
                    if debugModeEnabled {
                        Button("Generate Test Data") {
                            generateTestData()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Target Warnings", isPresented: $showingTargetWarnings) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(targetWarnings.joined(separator: "\n"))
            }
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your water entries, food entries, and step data. This action cannot be undone.")
            }
            .onAppear {
                loadCurrentTargets()
            }
        }
    }
    
    private func loadCurrentTargets() {
        waterTarget = String(Int(currentTargets.dailyWaterTarget))
        calorieTarget = String(currentTargets.dailyCalorieTarget)
        stepTarget = String(currentTargets.dailyStepTarget)
    }
    
    private func saveTargets() {
        var newTargets = currentTargets
        
        if let water = Double(waterTarget) {
            newTargets.dailyWaterTarget = water
        }
        if let calories = Int(calorieTarget) {
            newTargets.dailyCalorieTarget = calories
        }
        if let steps = Int(stepTarget) {
            newTargets.dailyStepTarget = steps
        }
        
        targetWarnings = newTargets.validateTargets()
        if !targetWarnings.isEmpty {
            showingTargetWarnings = true
        }
        
        // Update the existing targets in the database
        if let existingTargets = userTargets.first {
            existingTargets.dailyWaterTarget = newTargets.dailyWaterTarget
            existingTargets.dailyCalorieTarget = newTargets.dailyCalorieTarget
            existingTargets.dailyStepTarget = newTargets.dailyStepTarget
        } else {
            // If no targets exist, create new ones
            modelContext.insert(newTargets)
        }
        
        try? modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func resetAllData() {
        // Delete all food entries
        let foodDescriptor = FetchDescriptor<FoodEntry>()
        if let foodEntries = try? modelContext.fetch(foodDescriptor) {
            for entry in foodEntries {
                modelContext.delete(entry)
            }
        }
        
        // Delete all water entries
        let waterDescriptor = FetchDescriptor<WaterEntry>()
        if let waterEntries = try? modelContext.fetch(waterDescriptor) {
            for entry in waterEntries {
                modelContext.delete(entry)
            }
        }
        
        // Delete all step entries
        let stepDescriptor = FetchDescriptor<StepEntry>()
        if let stepEntries = try? modelContext.fetch(stepDescriptor) {
            for entry in stepEntries {
                modelContext.delete(entry)
            }
        }
        
        // Reset user targets
        if let targets = try? modelContext.fetch(FetchDescriptor<UserTargets>()).first {
            modelContext.delete(targets)
        }
        let defaultTargets = UserTargets()
        modelContext.insert(defaultTargets)
        
        try? modelContext.save()
    }
    
    private func generateTestData() {
        // Delete existing data first
        resetAllData()
        
        let calendar = Calendar.current
        let today = Date()
        
        // Generate 7 days of test data
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            
            // Add water entries
            let waterEntriesCount = Int.random(in: 3...8)
            let targetWater = 2000.0
            var remainingWater = targetWater * Double.random(in: 0.7...1.3)
            
            for i in 0..<waterEntriesCount {
                var randomAmount: Double
                if i == waterEntriesCount - 1 {
                    randomAmount = remainingWater
                } else {
                    randomAmount = remainingWater * Double.random(in: 0.1...0.5)
                }
                remainingWater -= randomAmount
                
                let randomHour = Int.random(in: 8...22)
                let randomMinute = Int.random(in: 0...59)
                let timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
                
                let entry = WaterEntry(amount: max(50, randomAmount))
                entry.timestamp = timestamp
                modelContext.insert(entry)
            }
            
            // Add food entries
            let foodCategories = ["Breakfast", "Lunch", "Dinner", "Snack"]
            let mealTimes = [
                "Breakfast": 7...9,
                "Lunch": 11...13,
                "Dinner": 18...20,
                "Snack": 10...21
            ]
            
            for category in foodCategories {
                if Double.random(in: 0...1) < 0.3 {
                    continue
                }
                
                let timeRange = mealTimes[category]!
                let randomHour = Int.random(in: timeRange)
                let randomMinute = Int.random(in: 0...59)
                let timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
                
                let entry = FoodEntry(
                    name: "Test \(category)",
                    category: category,
                    calories: Int.random(in: 200...800)
                )
                entry.timestamp = timestamp
                modelContext.insert(entry)
            }
            
            // Add step entry
            let isWeekend = calendar.isDateInWeekend(date)
            let baseSteps = isWeekend ? 2000 : 8000
            let randomSteps = Int.random(in: 0...7000)
            let steps = baseSteps + randomSteps
            
            let stepEntry = StepEntry(date: calendar.startOfDay(for: date), count: steps)
            modelContext.insert(stepEntry)
        }
        
        try? modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(NotificationManager.shared)
    }
} 
