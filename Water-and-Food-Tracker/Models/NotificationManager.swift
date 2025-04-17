import Foundation
import UserNotifications
import SwiftData

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var isWaterReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isWaterReminderEnabled, forKey: "isWaterReminderEnabled")
            if !isWaterReminderEnabled {
                removeWaterReminder()
            }
        }
    }
    @Published var isFoodReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isFoodReminderEnabled, forKey: "isFoodReminderEnabled")
            if !isFoodReminderEnabled {
                removeFoodReminder()
            }
        }
    }
    @Published var isProgressNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isProgressNotificationEnabled, forKey: "isProgressNotificationEnabled")
            if !isProgressNotificationEnabled {
                removeProgressNotifications()
            }
        }
    }
    @Published var waterReminderTime: Date {
        didSet {
            UserDefaults.standard.set(waterReminderTime, forKey: "waterReminderTime")
            if isWaterReminderEnabled {
                scheduleWaterReminder()
            }
        }
    }
    @Published var foodReminderTime: Date {
        didSet {
            UserDefaults.standard.set(foodReminderTime, forKey: "foodReminderTime")
            if isFoodReminderEnabled {
                scheduleFoodReminder()
            }
        }
    }
    @Published var progressNotificationTime: Date {
        didSet {
            UserDefaults.standard.set(progressNotificationTime, forKey: "progressNotificationTime")
            if isProgressNotificationEnabled, let context = modelContext {
                scheduleProgressNotifications(modelContext: context)
            }
        }
    }
    
    private var modelContext: ModelContext?
    
    private init() {
        self.isWaterReminderEnabled = UserDefaults.standard.bool(forKey: "isWaterReminderEnabled")
        self.isFoodReminderEnabled = UserDefaults.standard.bool(forKey: "isFoodReminderEnabled")
        self.isProgressNotificationEnabled = UserDefaults.standard.bool(forKey: "isProgressNotificationEnabled")
        self.waterReminderTime = UserDefaults.standard.object(forKey: "waterReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.foodReminderTime = UserDefaults.standard.object(forKey: "foodReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
        self.progressNotificationTime = UserDefaults.standard.object(forKey: "progressNotificationTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
        self.modelContext = nil
        checkAuthorizationStatus()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        if isProgressNotificationEnabled {
            scheduleProgressNotifications(modelContext: context)
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func scheduleWaterReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: waterReminderTime)
        let content = UNMutableNotificationContent()
        content.title = "Time to Hydrate! 💧"
        content.body = "Don't forget to drink water and stay hydrated!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleFoodReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: foodReminderTime)
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Food! 🍎"
        content.body = "Keep track of your meals for the day"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "foodReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleProgressNotifications(modelContext: ModelContext) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: progressNotificationTime)
        
        // Get the current progress
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Get water entries
        let waterDescriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate<WaterEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        let waterEntries = try? modelContext.fetch(waterDescriptor)
        let totalWater = waterEntries?.reduce(0) { $0 + $1.amount } ?? 0
        
        // Get food entries
        let foodDescriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        let foodEntries = try? modelContext.fetch(foodDescriptor)
        let totalCalories = foodEntries?.reduce(0) { $0 + $1.calories } ?? 0
        
        // Get step entries
        let stepDescriptor = FetchDescriptor<StepEntry>(
            predicate: #Predicate<StepEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        let stepEntries = try? modelContext.fetch(stepDescriptor)
        let totalSteps = stepEntries?.first?.count ?? 0
        
        // Get user targets
        let targetsDescriptor = FetchDescriptor<UserTargets>()
        guard let targets = try? modelContext.fetch(targetsDescriptor).first ?? UserTargets() else {
            print("Failed to get user targets")
            return
        }
        
        // Calculate progress percentages
        let waterProgress = min(1.0, totalWater / targets.dailyWaterTarget)
        let caloriesProgress = min(1.0, Double(totalCalories) / Double(targets.dailyCalorieTarget))
        let stepsProgress = min(1.0, Double(totalSteps) / Double(targets.dailyStepTarget))
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Progress Update 📊"
        content.body = """
        💧 Water: \(Int(totalWater))ml / \(Int(targets.dailyWaterTarget))ml (\(Int(waterProgress * 100))%)
        🍎 Calories: \(totalCalories)kcal / \(targets.dailyCalorieTarget)kcal (\(Int(caloriesProgress * 100))%)
        👣 Steps: \(totalSteps) / \(targets.dailyStepTarget) (\(Int(stepsProgress * 100))%)
        """
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "progressNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeWaterReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["waterReminder"])
    }
    
    private func removeFoodReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["foodReminder"])
    }
    
    private func removeProgressNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["progressNotification"])
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func sendProgressNotification(modelContext: ModelContext) {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Get water entries
        let waterDescriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate<WaterEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        let waterEntries = try? modelContext.fetch(waterDescriptor)
        let totalWater = waterEntries?.reduce(0) { $0 + $1.amount } ?? 0
        
        // Get food entries
        let foodDescriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.timestamp >= today && entry.timestamp < tomorrow
            }
        )
        let foodEntries = try? modelContext.fetch(foodDescriptor)
        let totalCalories = foodEntries?.reduce(0) { $0 + $1.calories } ?? 0
        
        // Get step entries
        let stepDescriptor = FetchDescriptor<StepEntry>(
            predicate: #Predicate<StepEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        let stepEntries = try? modelContext.fetch(stepDescriptor)
        let totalSteps = stepEntries?.first?.count ?? 0
        
        // Get user targets
        let targetsDescriptor = FetchDescriptor<UserTargets>()
        guard let targets = try? modelContext.fetch(targetsDescriptor).first ?? UserTargets() else {
            print("Failed to get user targets")
            return
        }
        
        // Calculate progress percentages
        let waterProgress = min(1.0, totalWater / targets.dailyWaterTarget)
        let caloriesProgress = min(1.0, Double(totalCalories) / Double(targets.dailyCalorieTarget))
        let stepsProgress = min(1.0, Double(totalSteps) / Double(targets.dailyStepTarget))
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Progress Update 📊"
        content.body = """
        💧 Water: \(Int(totalWater))ml / \(Int(targets.dailyWaterTarget))ml (\(Int(waterProgress * 100))%)
        🍎 Calories: \(totalCalories)kcal / \(targets.dailyCalorieTarget)kcal (\(Int(caloriesProgress * 100))%)
        👣 Steps: \(totalSteps) / \(targets.dailyStepTarget) (\(Int(stepsProgress * 100))%)
        """
        content.sound = .default
        
        // Send notification
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
} 
