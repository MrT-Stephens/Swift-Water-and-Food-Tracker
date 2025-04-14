//
//  Water_and_Food_TrackerApp.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 14/04/2025.
//

import SwiftUI
import SwiftData

@main
struct Water_and_Food_TrackerApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(healthKitManager)
        }
    }
}
