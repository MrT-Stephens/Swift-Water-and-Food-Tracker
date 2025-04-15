import Foundation

class AIMealService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateMealSuggestions(
        mealType: String,
        dietaryPreferences: [String],
        previousMeals: [String],
        targetCalories: Int? = nil
    ) async throws -> [MealSuggestion] {
        let prompt = createPrompt(
            mealType: mealType,
            dietaryPreferences: dietaryPreferences,
            previousMeals: previousMeals,
            targetCalories: targetCalories
        )
        
        print("Sending prompt to OpenAI: \(prompt)")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4.1",
            "messages": [
                ["role": "system", "content": "You are a nutritionist and chef that provides healthy meal suggestions."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("Error response: \(errorString)")
                    }
                    throw NSError(domain: "AIMealService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code \(httpResponse.statusCode)"])
                }
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw API response: \(responseString)")
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            let content = openAIResponse.choices.first?.message.content ?? ""
            print("Parsed content: \(content)")
            
            let suggestions = parseAIResponse(content)
            print("Parsed suggestions count: \(suggestions.count)")
            
            return suggestions
        } catch {
            print("Error in API call: \(error)")
            throw error
        }
    }
    
    private func createPrompt(
        mealType: String,
        dietaryPreferences: [String],
        previousMeals: [String],
        targetCalories: Int?
    ) -> String {
        var prompt = "Suggest 5 healthy \(mealType) options that are:"
        
        if !dietaryPreferences.isEmpty {
            prompt += "\n- \(dietaryPreferences.joined(separator: "\n- "))"
        }
        
        if !previousMeals.isEmpty {
            prompt += "\n\nPrevious meals to consider (avoid repeating these):"
            prompt += "\n- \(previousMeals.joined(separator: "\n- "))"
        }
        
        if let calories = targetCalories {
            prompt += "\n\nTarget calories: \(calories)"
        }
        
        prompt += """
        \n\nFor each suggestion, provide:
        - Name
        - Brief description
        - Calories
        - Protein (g)
        - Carbs (g)
        - Fat (g)
        - List of main ingredients
        - Preparation time in minutes
        - Difficulty level (Easy/Medium/Hard)
        
        Format each suggestion as a JSON object with these exact keys:
        {
            "name": "",
            "description": "",
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fat": 0,
            "ingredients": [],
            "preparationTime": 0,
            "difficulty": ""
        }
        
        Return an array of these objects. Make sure to provide exactly 5 different meal suggestions.
        """
        
        return prompt
    }
    
    private func parseAIResponse(_ response: String) -> [MealSuggestion] {
        // Try to extract JSON array from the response
        if let jsonData = response.data(using: .utf8) {
            do {
                let suggestions = try JSONDecoder().decode([MealSuggestion].self, from: jsonData)
                return suggestions
            } catch {
                print("Error parsing JSON: \(error)")
                print("Response that failed to parse: \(response)")
            }
        }
        return []
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}
