import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var waterTarget = ""
    @State private var calorieTarget = ""
    @State private var stepTarget = ""
    @State private var showingTargetWarnings = false
    @State private var targetWarnings: [String] = []
    @State private var showingResetConfirmation = false
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Targets")) {
                    HStack {
                        Text("Water Target")
                        Spacer()
                        TextField("ml", text: $waterTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("ml")
                    }
                    
                    HStack {
                        Text("Calorie Target")
                        Spacer()
                        TextField("kcal", text: $calorieTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                    }
                    
                    HStack {
                        Text("Step Target")
                        Spacer()
                        TextField("steps", text: $stepTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("steps")
                    }
                    
                    Button("Save Targets") {
                        saveTargets()
                    }
                    .disabled(waterTarget.isEmpty && calorieTarget.isEmpty && stepTarget.isEmpty)
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive, action: {
                        showingResetConfirmation = true
                    }) {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminders", isOn: .constant(true))
                    Toggle("Progress Updates", isOn: .constant(true))
                    Toggle("Target Alerts", isOn: .constant(true))
                }
                
                Section(header: Text("Debug")) {
                    Toggle("Enable Debug Mode", isOn: $debugModeEnabled)
                    
                    if debugModeEnabled {
                        Button("Generate Test Data") {
                            dataManager.resetAndInitializeWithDefaultData(extensive: true)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Target Warnings", isPresented: $showingTargetWarnings) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(targetWarnings.joined(separator: "\n"))
            }
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    dataManager.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your water entries, food entries, and step data. This action cannot be undone.")
            }
            .onAppear {
                loadCurrentTargets()
            }
        }
    }
    
    private func loadCurrentTargets() {
        waterTarget = String(Int(dataManager.userTargets.dailyWaterTarget))
        calorieTarget = String(dataManager.userTargets.dailyCalorieTarget)
        stepTarget = String(dataManager.userTargets.dailyStepTarget)
    }
    
    private func saveTargets() {
        var newTargets = dataManager.userTargets
        
        if let water = Double(waterTarget) {
            newTargets.dailyWaterTarget = water
        }
        if let calories = Int(calorieTarget) {
            newTargets.dailyCalorieTarget = calories
        }
        if let steps = Int(stepTarget) {
            newTargets.dailyStepTarget = steps
        }
        
        targetWarnings = newTargets.validateTargets()
        if !targetWarnings.isEmpty {
            showingTargetWarnings = true
        }
        
        dataManager.updateUserTargets(newTargets)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager())
    }
} 