import SwiftUI
import HealthKit

struct TestingView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useSimulatedData") private var useSimulatedData = false
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Data Management")) {
                    Button(action: {
                        dataManager.resetAndInitializeWithDefaultData(extensive: true)
                    }) {
                        Label("Reset & Initialize with Default Data", systemImage: "arrow.clockwise")
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("HealthKit")) {
                    Toggle("Use Simulated Data", isOn: $useSimulatedData)
                        .disabled(!debugModeEnabled)
                    
                    if !debugModeEnabled {
                        Text("Enable Debug Mode in Settings to use simulated data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if !useSimulatedData {
                        if healthKitManager.isAuthorized {
                            Text("HealthKit is authorized")
                                .foregroundColor(.green)
                        } else {
                            Button(action: {
                                healthKitManager.requestAuthorization()
                            }) {
                                Label("Request HealthKit Authorization", systemImage: "heart")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        if let error = healthKitManager.authorizationError {
                            Text(error)
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("Using simulated step data")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Current Data")) {
                    HStack {
                        Text("Water Entries:")
                        Spacer()
                        Text("\(dataManager.waterEntries.count)")
                    }
                    
                    HStack {
                        Text("Food Entries:")
                        Spacer()
                        Text("\(dataManager.foodEntries.count)")
                    }
                    
                    HStack {
                        Text("Step Entries:")
                        Spacer()
                        Text("\(dataManager.stepEntries.count)")
                    }
                }
            }
            .navigationTitle("Testing Tools")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TestingView()
        .environmentObject(DataManager())
        .environmentObject(HealthKitManager())
} 
