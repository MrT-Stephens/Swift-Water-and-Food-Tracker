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
    
    private let tabs = [
        (title: "Dashboard", icon: "chart.bar.fill", view: AnyView(DashboardView())),
        (title: "Food", icon: "fork.knife", view: AnyView(FoodTrackingView())),
        (title: "Water", icon: "drop.fill", view: AnyView(WaterTrackingView())),
        (title: "History", icon: "clock.fill", view: AnyView(HistoryView())),
        (title: "AI Meals", icon: "brain.head.profile", view: AnyView(AIMealSuggestionsView())),
        (title: "Settings", icon: "gear", view: AnyView(SettingsView()))
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content View
            ZStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    tabs[index].view
                        .opacity(selectedTab == index ? 1 : 0)
                        .animation(.easeInOut, value: selectedTab)
                }
            }
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                Divider()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedTab = index
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tabs[index].icon)
                                        .font(.system(size: 22))
                                    Text(tabs[index].title)
                                        .font(.caption)
                                }
                                .frame(width: 80)
                                .padding(.vertical, 8)
                                .background(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: -1)
        }
        .environmentObject(healthKitManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
