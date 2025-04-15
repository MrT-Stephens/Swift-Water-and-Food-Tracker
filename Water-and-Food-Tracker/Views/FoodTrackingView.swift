import SwiftUI
import SwiftData

struct FoodTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddFood = false
    @State private var selectedCategory = "Breakfast"
    @State private var foodName = ""
    @State private var calories = ""
    @State private var notes = ""
    
    @Query private var foodEntries: [FoodEntry]
    
    private var dailyFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return foodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }
    
    let categories = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Food Entries")) {
                    ForEach(dailyFoodEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.headline)
                            HStack {
                                Text(entry.category)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(entry.calories) kcal")
                                    .font(.subheadline)
                            }
                            if let notes = entry.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Food Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                NavigationView {
                    Form {
                        Section(header: Text("Food Details")) {
                            TextField("Food Name", text: $foodName)
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            TextField("Calories", text: $calories)
                                .keyboardType(.numberPad)
                            TextField("Notes (Optional)", text: $notes)
                        }
                    }
                    .navigationTitle("Add Food")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddFood = false
                        },
                        trailing: Button("Save") {
                            saveFoodEntry()
                        }
                        .disabled(foodName.isEmpty || calories.isEmpty)
                    )
                }
            }
        }
    }
    
    private func saveFoodEntry() {
        guard let caloriesInt = Int(calories) else { return }
        
        let entry = FoodEntry(
            name: foodName,
            category: selectedCategory,
            calories: caloriesInt,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(entry)
        try? modelContext.save()
        
        // Reset form
        foodName = ""
        calories = ""
        notes = ""
        showingAddFood = false
    }
}

struct FoodTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        FoodTrackingView()
    }
} 