import Foundation
import MapKit
import CoreLocation

class TripSuggestionService {
    private let apiKey = "sk-proj-gXmhbiYth" 

    func fetchNextTripSuggestion(from journals: [JournalEntry], completion: @escaping (String?) -> Void) {
        let visited = journals.map { $0.region }.joined(separator: ", ")

        let prompt = """
        The user has previously traveled to: \(visited).
        Based on their travel history, suggest one unique next destination that aligns with their travel style.
        Respond ONLY in this exact JSON format:

        {
            "city": "CityName",
            "country": "CountryName",
            "description": "One sentence poetic reason to go there"
        }
        """

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You're a travel advisor. Respond ONLY in valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = result["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let jsonData = content.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String],
                  let city = json["city"], let country = json["country"], let description = json["description"] else {
                DispatchQueue.main.async {
                    completion("⚠️ Couldn't parse a valid suggestion. Try again.")
                }
                return
            }

            let resultText = "\(city), \(country): \(description)"
            DispatchQueue.main.async {
                completion(resultText)
            }
        }.resume()
    }
}

struct TripSuggestion {
    let name: String
    let region: String
    let coordinate: CLLocationCoordinate2D
}
