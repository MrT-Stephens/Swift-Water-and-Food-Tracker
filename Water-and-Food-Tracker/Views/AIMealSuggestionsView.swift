import SwiftUI
import SwiftData
import WidgetKit

struct AIMealSuggestionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var foodEntries: [FoodEntry]
    @Query private var userTargets: [UserTargets]
    
    @State private var selectedMealType: MealType? = nil
    @State private var suggestions: [MealSuggestion] = []
    @State private var isLoading = false
    @State private var showingDetail = false
    @State private var selectedSuggestion: MealSuggestion?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    @State private var dietaryPreferences: [String] = []
    @State private var targetCalories: Int?
    
    private let aiService = AIMealService(apiKey: "") // Replace with actual API key
    
    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preferences Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Preferences")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(["Vegetarian", "Vegan", "Gluten-Free", "Low-Carb", "High-Protein"], id: \.self) { preference in
                                Button(action: {
                                    togglePreference(preference)
                                }) {
                                    Text(preference)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(dietaryPreferences.contains(preference) ? 
                                                   Color.blue.opacity(0.8) : 
                                                   Color.gray.opacity(0.1))
                                        .foregroundColor(dietaryPreferences.contains(preference) ? .white : .primary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(dietaryPreferences.contains(preference) ? 
                                                       Color.blue.opacity(0.8) : 
                                                       Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Target Calories:")
                            .foregroundColor(.secondary)
                        TextField("Optional", value: $targetCalories, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .keyboardType(.numberPad)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Meal type selector
                VStack(alignment: .leading, spacing: 15) {
                    Text("Meal Type")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Button(action: {
                                    selectedMealType = type
                                    generateSuggestions()
                                }) {
                                    Text(type.rawValue)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(selectedMealType == type ? 
                                                   Color.blue.opacity(0.8) : 
                                                   Color.gray.opacity(0.1))
                                        .foregroundColor(selectedMealType == type ? .white : .primary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedMealType == type ? 
                                                       Color.blue.opacity(0.8) : 
                                                       Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Generating meal suggestions...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else if suggestions.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.7))
                        Text(selectedMealType == nil ? "Select a meal type to get started" : "No suggestions yet")
                            .font(.headline)
                        Text(selectedMealType == nil ? "Choose from Breakfast, Lunch, Dinner, or Snack" : "Try adjusting your preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Suggestions")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        
                        ForEach(suggestions) { suggestion in
                            MealSuggestionCard(
                                suggestion: suggestion,
                                mealType: selectedMealType?.rawValue ?? ""
                            )
                            .onTapGesture {
                                selectedSuggestion = suggestion
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    showingDetail = true
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("AI Meal Suggestions")
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingDetail) {
            if let suggestion = selectedSuggestion, let mealType = selectedMealType?.rawValue {
                MealDetailView(suggestion: suggestion, mealType: mealType)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func togglePreference(_ preference: String) {
        if dietaryPreferences.contains(preference) {
            dietaryPreferences.removeAll { $0 == preference }
        } else {
            dietaryPreferences.append(preference)
        }
    }
    
    private func generateSuggestions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let previousMeals = foodEntries.map { $0.name }
                suggestions = try await aiService.generateMealSuggestions(
                    mealType: selectedMealType?.rawValue ?? MealType.breakfast.rawValue,
                    dietaryPreferences: dietaryPreferences,
                    previousMeals: previousMeals,
                    targetCalories: targetCalories
                )
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isLoading = false
        }
    }
}

struct MealSuggestionCard: View {
    let suggestion: MealSuggestion
    let mealType: String
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(suggestion.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    addToFoodEntries()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(suggestion.calories) cal", systemImage: "flame.fill")
                    Label("\(suggestion.preparationTime) min", systemImage: "clock")
                    Label(suggestion.difficulty, systemImage: "chart.bar.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Protein: \(suggestion.protein)g")
                    Text("Carbs: \(suggestion.carbs)g")
                    Text("Fat: \(suggestion.fat)g")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func addToFoodEntries() {
        let macronutrients = "Protein: \(suggestion.protein)g, Carbs: \(suggestion.carbs)g, Fat: \(suggestion.fat)g"
        let foodEntry = FoodEntry(
            name: suggestion.name,
            category: mealType,
            calories: suggestion.calories,
            notes: macronutrients
        )
        modelContext.insert(foodEntry)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct MealDetailView: View {
    let suggestion: MealSuggestion
    let mealType: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(suggestion.name)
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                        
                        Text(suggestion.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Nutrition Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Nutrition Information")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 15) {
                            NutritionInfoView(value: suggestion.calories, unit: "cal", label: "Calories")
                            NutritionInfoView(value: suggestion.protein, unit: "g", label: "Protein")
                            NutritionInfoView(value: suggestion.carbs, unit: "g", label: "Carbs")
                            NutritionInfoView(value: suggestion.fat, unit: "g", label: "Fat")
                        }
                    }
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(suggestion.ingredients, id: \.self) { ingredient in
                                HStack(spacing: 10) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.blue)
                                    Text(ingredient)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Preparation Info
                    HStack {
                        Label("\(suggestion.preparationTime) minutes", systemImage: "clock")
                            .foregroundColor(.secondary)
                        Spacer()
                        Label(suggestion.difficulty, systemImage: "chart.bar.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add to Diary") {
                        addToFoodEntries()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func addToFoodEntries() {
        let macronutrients = "Protein: \(suggestion.protein)g, Carbs: \(suggestion.carbs)g, Fat: \(suggestion.fat)g"
        let foodEntry = FoodEntry(
            name: suggestion.name,
            category: mealType,
            calories: suggestion.calories,
            notes: macronutrients
        )
        modelContext.insert(foodEntry)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct NutritionInfoView: View {
    let value: Int
    let unit: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)\(unit)")
                .font(.headline)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AIMealSuggestionsView()
        .modelContainer(for: [FoodEntry.self, UserTargets.self])
} 
