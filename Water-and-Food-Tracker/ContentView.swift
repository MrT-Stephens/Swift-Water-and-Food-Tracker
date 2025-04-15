//
//  ContentView.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 14/04/2025.
//

import SwiftUI
import HealthKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            FoodTrackingView()
                .tabItem {
                    Label("Food", systemImage: "fork.knife")
                }
                .tag(1)
            
            WaterTrackingView()
                .tabItem {
                    Label("Water", systemImage: "drop.fill")
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .environmentObject(healthKitManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
