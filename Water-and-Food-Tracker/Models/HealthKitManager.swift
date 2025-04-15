import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var authorizationError: String?
    @Published var isRequestingAuthorization = false
    
    // Set this to true to use simulated data instead of real HealthKit data
    @AppStorage("useSimulatedData") private var useSimulatedData = false
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    
    public init() {
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationError = "HealthKit is not available on this device"
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let status = healthStore.authorizationStatus(for: stepType)
        
        DispatchQueue.main.async {
            self.isAuthorized = status == .sharingAuthorized
            if status == .notDetermined {
                self.authorizationError = "HealthKit authorization not determined"
            } else if status == .sharingDenied {
                self.authorizationError = "HealthKit authorization was denied"
            }
        }
    }
    
    func requestAuthorization() {
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.authorizationError = "HealthKit is not available on this device"
                self.isRequestingAuthorization = false
            }
            return
        }
        
        // Define the types of data we want to read
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Set requesting state
        DispatchQueue.main.async {
            self.isRequestingAuthorization = true
            self.authorizationError = nil
        }
        
        // Request authorization
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            DispatchQueue.main.async {
                self.isRequestingAuthorization = false
                self.isAuthorized = success
                
                if let error = error {
                    self.authorizationError = "Authorization failed: \(error.localizedDescription)"
                } else if !success {
                    self.authorizationError = "HealthKit authorization was denied"
                } else {
                    self.authorizationError = nil
                }
            }
        }
    }
    
    func fetchStepCount(from startDate: Date, to endDate: Date) async throws -> [Date: Int] {
        // Only use simulated data if debug mode is enabled
        if debugModeEnabled && useSimulatedData {
            return generateSimulatedStepData(from: startDate, to: endDate)
        }
        
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var results: [Date: Int] = [:]
            let calendar = Calendar.current
            
            query.initialResultsHandler = { query, statisticsCollection, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let statisticsCollection = statisticsCollection else {
                    continuation.resume(throwing: HealthKitError.dataNotAvailable)
                    return
                }
                
                statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    if let sum = statistics.sumQuantity() {
                        let steps = Int(sum.doubleValue(for: HKUnit.count()))
                        let date = calendar.startOfDay(for: statistics.startDate)
                        results[date] = steps
                    }
                }
                
                continuation.resume(returning: results)
            }
            
            healthStore.execute(query)
        }
    }
    
    // Function to generate simulated step data for testing
    public func generateSimulatedStepData(from startDate: Date, to endDate: Date) -> [Date: Int] {
        var results: [Date: Int] = [:]
        let calendar = Calendar.current
        
        var currentDate = startDate
        while currentDate <= endDate {
            let date = calendar.startOfDay(for: currentDate)
            
            // Generate a random step count between 2000 and 15000
            // Higher counts on weekdays, lower on weekends
            let isWeekend = calendar.isDateInWeekend(date)
            let baseSteps = isWeekend ? 2000 : 8000
            
            // Add some randomness to make it more realistic
            let randomSteps = Int.random(in: 0...7000)
            let steps = baseSteps + randomSteps
            
            results[date] = steps
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return results
    }
}

enum HealthKitError: Error {
    case notAuthorized
    case dataNotAvailable
} 
