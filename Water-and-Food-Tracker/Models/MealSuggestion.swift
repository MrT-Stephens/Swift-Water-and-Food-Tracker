import Foundation

struct MealSuggestion: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let ingredients: [String]
    let preparationTime: Int
    let difficulty: String
} 