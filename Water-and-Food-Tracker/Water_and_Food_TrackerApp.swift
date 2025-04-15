//
//  Water_and_Food_TrackerApp.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 14/04/2025.
//

import SwiftUI
import SwiftData
import HealthKit
import UserNotifications

@main
struct Water_and_Food_TrackerApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                FoodEntry.self,
                WaterEntry.self,
                UserTargets.self,
                StepEntry.self
            ])
            
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mrt-stephens.water-and-food-tracker")!
            
            let modelConfiguration = ModelConfiguration(schema: schema, url: containerURL.appendingPathComponent("Water-and-Food-Tracker.db"))
            
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
        .modelContainer(container)
    }
}
