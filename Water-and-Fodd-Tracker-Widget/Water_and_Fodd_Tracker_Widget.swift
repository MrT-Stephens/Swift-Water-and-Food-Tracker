//
//  Water_and_Fodd_Tracker_Widget.swift
//  Water-and-Fodd-Tracker-Widget
//
//  Created by Thomas Stephens on 15/04/2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), waterProgress: 0.5, caloriesProgress: 0.3, stepsProgress: 0.7)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), waterProgress: 0.5, caloriesProgress: 0.3, stepsProgress: 0.7)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get the shared container URL
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mrt-stephens.water-and-food-tracker")!
        
        let databaseURL = containerURL.appendingPathComponent("Water-and-Food-Tracker.db")
        
        // Configure SwiftData
        let schema = Schema([
            FoodEntry.self,
            WaterEntry.self,
            UserTargets.self,
            StepEntry.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: databaseURL)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            // Get today's entries
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Get water entries
            let waterDescriptor = FetchDescriptor<WaterEntry>(
                predicate: #Predicate<WaterEntry> { entry in
                    entry.timestamp >= today && entry.timestamp < tomorrow
                }
            )
            let waterEntries = try context.fetch(waterDescriptor)
            let totalWater = waterEntries.reduce(0) { $0 + $1.amount }
            
            // Get food entries
            let foodDescriptor = FetchDescriptor<FoodEntry>(
                predicate: #Predicate<FoodEntry> { entry in
                    entry.timestamp >= today && entry.timestamp < tomorrow
                }
            )
            let foodEntries = try context.fetch(foodDescriptor)
            let totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
            
            // Get step entries
            let stepDescriptor = FetchDescriptor<StepEntry>(
                predicate: #Predicate<StepEntry> { entry in
                    entry.date >= today && entry.date < tomorrow
                }
            )
            let stepEntries = try context.fetch(stepDescriptor)
            let totalSteps = stepEntries.first?.count ?? 0
            
            // Get user targets
            let targetsDescriptor = FetchDescriptor<UserTargets>()
            let targets = try context.fetch(targetsDescriptor).first ?? UserTargets()
            
            // Calculate progress
            let waterProgress = min(1.0, totalWater / targets.dailyWaterTarget)
            let caloriesProgress = min(1.0, Double(totalCalories) / Double(targets.dailyCalorieTarget))
            let stepsProgress = min(1.0, Double(totalSteps) / Double(targets.dailyStepTarget))
            
            let entry = SimpleEntry(
                date: Date(),
                waterProgress: waterProgress,
                caloriesProgress: caloriesProgress,
                stepsProgress: stepsProgress
            )
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            
        } catch {
            print("Error fetching data for widget: \(error)")
            let entry = SimpleEntry(date: Date(), waterProgress: 0.0, caloriesProgress: 0.0, stepsProgress: 0.0)
            let timeline = Timeline(entries: [entry], policy: .after(Date()))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let waterProgress: Double
    let caloriesProgress: Double
    let stepsProgress: Double
}

struct Water_and_Fodd_Tracker_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            Text("Unsupported widget size")
        }
    }
}

struct Water_and_Fodd_Tracker_Widget: Widget {
    let kind: String = "Water_and_Fodd_Tracker_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Water_and_Fodd_Tracker_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Progress")
        .description("Track your daily water, food, and step progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    Water_and_Fodd_Tracker_Widget()
} timeline: {
    SimpleEntry(date: .now, waterProgress: 0.5, caloriesProgress: 0.3, stepsProgress: 0.7)
    SimpleEntry(date: .now, waterProgress: 0.8, caloriesProgress: 0.6, stepsProgress: 0.9)
}
