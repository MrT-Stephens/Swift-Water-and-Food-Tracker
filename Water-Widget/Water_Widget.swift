//
//  Water_Widget.swift
//  Water-Widget
//
//  Created by Thomas Stephens on 14/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WaterFoodEntry {
        WaterFoodEntry(date: Date(), waterIntake: 500, foodIntake: 1200)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterFoodEntry) -> ()) {
        let waterIntake = SharedDataManager.shared.getTodayWaterIntake()
        let foodIntake = SharedDataManager.shared.getTodayFoodIntake()
        let entry = WaterFoodEntry(date: Date(), waterIntake: waterIntake, foodIntake: foodIntake)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let waterIntake = SharedDataManager.shared.getTodayWaterIntake()
        let foodIntake = SharedDataManager.shared.getTodayFoodIntake()
        
        let entry = WaterFoodEntry(date: Date(), waterIntake: waterIntake, foodIntake: foodIntake)
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct WaterFoodEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let foodIntake: Double
}

struct Water_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            smallWidgetView
        }
    }
    
    private var smallWidgetView: some View {
        VStack(spacing: 8) {
            Text("Today's Progress")
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("\(Int(entry.waterIntake))ml")
                        .font(.caption)
                        .bold()
                }
                
                VStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("\(Int(entry.foodIntake))kcal")
                        .font(.caption)
                        .bold()
                }
            }
        }
        .padding()
    }
    
    private var mediumWidgetView: some View {
        VStack(spacing: 12) {
            Text("Today's Progress")
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                    Text("Water")
                        .font(.caption)
                    Text("\(Int(entry.waterIntake))ml")
                        .font(.title3)
                        .bold()
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.green)
                        .font(.title)
                    Text("Food")
                        .font(.caption)
                    Text("\(Int(entry.foodIntake))kcal")
                        .font(.title3)
                        .bold()
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct Water_Widget: Widget {
    let kind: String = "Water_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Water_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water & Food Tracker")
        .description("Track your daily water and food intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    Water_Widget()
} timeline: {
    WaterFoodEntry(date: .now, waterIntake: 500, foodIntake: 1200)
}

#Preview(as: .systemMedium) {
    Water_Widget()
} timeline: {
    WaterFoodEntry(date: .now, waterIntake: 500, foodIntake: 1200)
}
