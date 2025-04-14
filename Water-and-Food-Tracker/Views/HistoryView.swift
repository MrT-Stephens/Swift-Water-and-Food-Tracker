import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var selectedTimeRange: TimeRange = .week
    @State private var stepData: [DailyData] = []
    @State private var isLoadingSteps = false
    @State private var stepError: String?
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
        
        var xAxisStride: Calendar.Component {
            switch self {
            case .week: return .day
            case .month: return .day
            case .year: return .month
            }
        }
        
        var xAxisFormat: Date.FormatStyle {
            switch self {
            case .week: return .dateTime.weekday(.abbreviated)
            case .month: return .dateTime.day()
            case .year: return .dateTime.month(.abbreviated)
            }
        }
        
        var xAxisStrideCount: Int {
            switch self {
            case .week: return 1
            case .month: return 1  // Show every day
            case .year: return 1
            }
        }
        
        var labelRotation: Double {
            switch self {
            case .week: return 0
            case .month: return -45  // Rotate for month view to prevent overlap
            case .year: return 0
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                timeRangePicker
                ScrollView {
                    VStack(spacing: 20) {
                        waterChart
                        calorieChart
                        stepChart
                    }
                    .padding()
                }
            }
            .navigationTitle("History")
            .onChange(of: selectedTimeRange) { _ in
                Task {
                    await fetchStepData()
                }
            }
            .task {
                await fetchStepData()
            }
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var waterChart: some View {
        ChartCard(title: "Water Consumption") {
            Chart {
                ForEach(getWaterData(), id: \.date) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: selectedTimeRange.xAxisStride),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: selectedTimeRange.xAxisFormat)
                                .rotationEffect(.degrees(selectedTimeRange.labelRotation))
                        }
                    }
                }
            }
        }
    }
    
    private var calorieChart: some View {
        ChartCard(title: "Calorie Intake") {
            Chart {
                ForEach(getCalorieData(), id: \.date) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: selectedTimeRange.xAxisStride),
                        y: .value("Calories", data.calories)
                    )
                    .foregroundStyle(Color.orange.gradient)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: selectedTimeRange.xAxisFormat)
                                .rotationEffect(.degrees(selectedTimeRange.labelRotation))
                        }
                    }
                }
            }
        }
    }
    
    private var stepChart: some View {
        ChartCard(title: "Step Count") {
            if isLoadingSteps {
                ProgressView()
                    .frame(height: 200)
            } else if let error = stepError {
                Text(error)
                    .foregroundColor(.red)
                    .frame(height: 200)
            } else {
                Chart {
                    ForEach(stepData, id: \.date) { data in
                        BarMark(
                            x: .value("Date", data.date, unit: selectedTimeRange.xAxisStride),
                            y: .value("Steps", data.steps)
                        )
                        .foregroundStyle(Color.green.gradient)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(preset: .aligned) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: selectedTimeRange.xAxisFormat)
                                    .rotationEffect(.degrees(selectedTimeRange.labelRotation))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getWaterData() -> [DailyData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate)!
        
        // Get actual data
        let actualData = dataManager.waterEntries
            .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
            .reduce(into: [Date: Double]()) { result, entry in
                let date = calendar.startOfDay(for: entry.timestamp)
                result[date, default: 0] += entry.amount
            }
        
        // Create a complete set of dates for the time range
        var completeData: [Date: Double] = [:]
        
        // Generate all dates in the range
        var currentDate = startDate
        while currentDate <= endDate {
            let date = calendar.startOfDay(for: currentDate)
            completeData[date] = actualData[date] ?? 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return completeData.map { DailyData(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private func getCalorieData() -> [DailyData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate)!
        
        // Get actual data
        let actualData = dataManager.foodEntries
            .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
            .reduce(into: [Date: Int]()) { result, entry in
                let date = calendar.startOfDay(for: entry.timestamp)
                result[date, default: 0] += entry.calories
            }
        
        // Create a complete set of dates for the time range
        var completeData: [Date: Int] = [:]
        
        // Generate all dates in the range
        var currentDate = startDate
        while currentDate <= endDate {
            let date = calendar.startOfDay(for: currentDate)
            completeData[date] = actualData[date] ?? 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return completeData.map { DailyData(date: $0.key, calories: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private func fetchStepData() async {
        guard healthKitManager.isAuthorized else {
            stepError = "HealthKit access not authorized"
            return
        }
        
        isLoadingSteps = true
        stepError = nil
        
        do {
            let calendar = Calendar.current
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate)!
            
            let stepCounts = try await healthKitManager.fetchStepCount(from: startDate, to: endDate)
            
            // Create a complete set of dates for the time range
            var completeData: [Date: Int] = [:]
            
            // Generate all dates in the range
            var currentDate = startDate
            while currentDate <= endDate {
                let date = calendar.startOfDay(for: currentDate)
                // Get the step count for this date, defaulting to 0 if not found
                let steps = stepCounts[date] ?? 0
                completeData[date] = steps
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            await MainActor.run {
                // Convert to DailyData array and sort by date
                stepData = completeData.map { DailyData(date: $0.key, steps: $0.value) }
                    .sorted { $0.date < $1.date }
                isLoadingSteps = false
            }
        } catch {
            await MainActor.run {
                stepError = "Failed to fetch step data: \(error.localizedDescription)"
                isLoadingSteps = false
            }
        }
    }
}

struct DailyData: Identifiable {
    let id = UUID()
    let date: Date
    var amount: Double = 0
    var calories: Int = 0
    var steps: Int = 0
    
    init(date: Date, amount: Double = 0, calories: Int = 0, steps: Int = 0) {
        // Normalize the date to start of day for consistency
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.amount = amount
        self.calories = calories
        self.steps = steps
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            content
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(DataManager())
    }
} 
