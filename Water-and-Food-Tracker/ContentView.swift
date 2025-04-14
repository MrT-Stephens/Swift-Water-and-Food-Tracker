//
//  ContentView.swift
//  Water-and-Food-Tracker
//
//  Created by Thomas Stephens on 14/04/2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var selectedTab = 0
    @State private var showingTestingView = false
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    
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
        .environmentObject(dataManager)
        .environmentObject(healthKitManager)
        .overlay(alignment: .topTrailing) {
            if debugModeEnabled {
                Button(action: {
                    showingTestingView = true
                }) {
                    Image(systemName: "hammer.fill")
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingTestingView) {
            TestingView()
                .environmentObject(dataManager)
                .environmentObject(healthKitManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
