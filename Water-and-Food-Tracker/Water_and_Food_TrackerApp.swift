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
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
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
