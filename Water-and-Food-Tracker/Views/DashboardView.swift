import SwiftUI
import UIKit
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var isLoadingSteps = false
    @State private var stepError: String?
    @State private var currentStepCount: Int = 0
    
    @Query private var foodEntries: [FoodEntry]
    @Query private var waterEntries: [WaterEntry]
    @Query private var userTargets: [UserTargets]
    
    private var currentTargets: UserTargets {
        userTargets.first ?? UserTargets()
    }
    
    private var dailyFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return foodEntries.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
    }
    
    private var dailyWaterEntries: [WaterEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return waterEntries.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
    }
    
    private var totalWaterConsumption: Double {
        dailyWaterEntries.reduce(0) { $0 + $1.amount }
    }
    
    private var totalCalories: Int {
        dailyFoodEntries.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Water Progress
                    ProgressCard(
                        title: "Water Intake",
                        current: totalWaterConsumption,
                        target: currentTargets.dailyWaterTarget,
                        unit: "ml",
                        color: .blue
                    )
                    
                    // Calories Progress
                    ProgressCard(
                        title: "Calories",
                        current: Double(totalCalories),
                        target: Double(currentTargets.dailyCalorieTarget),
                        unit: "kcal",
                        color: .orange
                    )
                    
                    // Steps Progress
                    ProgressCard(
                        title: "Steps",
                        current: Double(currentStepCount),
                        target: Double(currentTargets.dailyStepTarget),
                        unit: "steps",
                        color: .green,
                        isLoading: isLoadingSteps,
                        error: stepError
                    )
                    
                    if !healthKitManager.isAuthorized {
                        Button(action: {
                            healthKitManager.requestAuthorization()
                        }) {
                            Text("Enable Step Tracking")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Entries
                    VStack(alignment: .leading) {
                        Text("Recent Entries")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Combine and sort food and water entries
                        let recentEntries = getRecentEntries()
                        
                        if recentEntries.isEmpty {
                            Text("No entries today")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(recentEntries.prefix(5)) { entry in
                                HStack {
                                    Image(systemName: entry.type == .food ? "fork.knife" : "drop.fill")
                                        .foregroundColor(entry.type == .food ? .orange : .blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(entry.title)
                                            .font(.subheadline)
                                        Text(entry.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(entry.detail)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 1)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                fetchCurrentStepCount()
            }
            .onChange(of: healthKitManager.isAuthorized) { newValue in
                if newValue {
                    fetchCurrentStepCount()
                }
            }
            .refreshable {
                fetchCurrentStepCount()
            }
        }
    }
    
    private func fetchCurrentStepCount() {
        guard healthKitManager.isAuthorized else {
            stepError = "Step tracking not authorized"
            return
        }
        
        isLoadingSteps = true
        stepError = nil
        
        Task {
            do {
                let calendar = Calendar.current
                let endDate = Date()
                let startDate = calendar.startOfDay(for: endDate)
                
                let stepCounts = try await healthKitManager.fetchStepCount(from: startDate, to: endDate)
                
                await MainActor.run {
                    if let todaySteps = stepCounts[startDate] {
                        updateStepCount(todaySteps)
                        stepError = nil
                    } else {
                        stepError = "No step data available for today"
                    }
                    isLoadingSteps = false
                }
            } catch {
                await MainActor.run {
                    stepError = "Failed to fetch steps: \(error.localizedDescription)"
                    isLoadingSteps = false
                }
            }
        }
    }
    
    private func updateStepCount(_ count: Int) {
        currentStepCount = count
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Create or update step entry for today
        let descriptor = FetchDescriptor<StepEntry>(
            predicate: #Predicate<StepEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        
        if let existingEntry = try? modelContext.fetch(descriptor).first {
            existingEntry.count = count
        } else {
            let newEntry = StepEntry(date: today, count: count)
            modelContext.insert(newEntry)
        }
        
        try? modelContext.save()
    }
    
    private func getRecentEntries() -> [RecentEntry] {
        var entries: [RecentEntry] = []
        
        // Add food entries
        for entry in dailyFoodEntries {
            entries.append(RecentEntry(
                id: entry.id,
                type: .food,
                title: entry.name,
                detail: "\(entry.calories) kcal",
                timestamp: entry.timestamp
            ))
        }
        
        // Add water entries
        for entry in dailyWaterEntries {
            entries.append(RecentEntry(
                id: entry.id,
                type: .water,
                title: "Water",
                detail: "\(Int(entry.amount)) ml",
                timestamp: entry.timestamp
            ))
        }
        
        // Sort by timestamp (most recent first)
        return entries.sorted { $0.timestamp > $1.timestamp }
    }
}

struct RecentEntry: Identifiable {
    let id: UUID
    let type: EntryType
    let title: String
    let detail: String
    let timestamp: Date
    
    enum EntryType {
        case food
        case water
    }
}

struct ProgressCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    var isLoading: Bool = false
    var error: String? = nil
    
    var progress: Double {
        min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            HStack {
                Text("\(Int(current))")
                    .font(.title)
                    .bold()
                
                Text("/ \(Int(target)) \(unit)")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.3)
                        .foregroundColor(color)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 20)
                        .foregroundColor(color)
                }
                .cornerRadius(10)
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    DashboardView()
        .environmentObject(HealthKitManager())
} 
