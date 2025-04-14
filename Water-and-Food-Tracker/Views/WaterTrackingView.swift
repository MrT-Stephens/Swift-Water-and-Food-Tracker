import SwiftUI

struct WaterTrackingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddWater = false
    @State private var amount = ""
    
    let commonAmounts = [100, 200, 300, 500]
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(dataManager.getTotalWaterConsumption() / dataManager.userTargets.dailyWaterTarget, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    VStack {
                        Text("\(Int(dataManager.getTotalWaterConsumption()))ml")
                            .font(.title)
                            .bold()
                        Text("of \(Int(dataManager.userTargets.dailyWaterTarget))ml")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                .padding()
                
                // Quick Add Buttons
                VStack(alignment: .leading) {
                    Text("Quick Add")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(commonAmounts, id: \.self) { amount in
                                Button(action: {
                                    addWaterEntry(amount: Double(amount))
                                }) {
                                    Text("+\(amount)ml")
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Today's Entries
                List {
                    Section(header: Text("Today's Water Intake")) {
                        ForEach(dataManager.getDailyWaterEntries()) { entry in
                            HStack {
                                Text("\(Int(entry.amount))ml")
                                Spacer()
                                Text(entry.timestamp, style: .time)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Water Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWater = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWater) {
                NavigationView {
                    Form {
                        Section(header: Text("Add Water")) {
                            TextField("Amount (ml)", text: $amount)
                                .keyboardType(.numberPad)
                        }
                    }
                    .navigationTitle("Add Water")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddWater = false
                        },
                        trailing: Button("Save") {
                            if let amountDouble = Double(amount) {
                                addWaterEntry(amount: amountDouble)
                            }
                        }
                        .disabled(amount.isEmpty)
                    )
                }
            }
        }
    }
    
    private func addWaterEntry(amount: Double) {
        let entry = WaterEntry(amount: amount)
        dataManager.addWaterEntry(entry)
        self.amount = ""
        showingAddWater = false
    }
}

struct WaterTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        WaterTrackingView()
            .environmentObject(DataManager())
    }
} 