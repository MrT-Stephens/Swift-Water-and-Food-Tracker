import Foundation
import UserNotifications

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
    
    private init() {
        self.isWaterReminderEnabled = UserDefaults.standard.bool(forKey: "isWaterReminderEnabled")
        self.isFoodReminderEnabled = UserDefaults.standard.bool(forKey: "isFoodReminderEnabled")
        self.waterReminderTime = UserDefaults.standard.object(forKey: "waterReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.foodReminderTime = UserDefaults.standard.object(forKey: "foodReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
        checkAuthorizationStatus()
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
    
    private func removeWaterReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["waterReminder"])
    }
    
    private func removeFoodReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["foodReminder"])
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 