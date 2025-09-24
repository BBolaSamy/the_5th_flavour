
import Foundation


class GPTService {
    private let apiKey: String
    
    init() {
        // Priority order: Environment Variable > Keychain > Info.plist
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            self.apiKey = envKey
            print("🔐 Using API key from environment variable")
        } else if let keychainKey = KeychainHelper.shared.retrieve(key: "OpenAIAPIKey") {
            self.apiKey = keychainKey
            print("🔐 Using API key from Keychain")
        } else if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String {
            self.apiKey = plistKey
            print("🔐 Using API key from Info.plist")
        } else {
            self.apiKey = ""
            print("⚠️ WARNING: OpenAI API key not found. Please set OPENAI_API_KEY environment variable, add to Keychain, or add OpenAIAPIKey to Info.plist")
        }
    }

    /// Generate a prompt from metadata
    private func buildPrompt(from metadata: MediaMetadataSummary) -> String {
        return """
        You are a personal travel journaling assistant. Based on the following metadata from a trip, write a short, warm, and descriptive memory as if the user is narrating it.

        Location: \(metadata.location)
        Date & Time: \(metadata.date)
        People: \(metadata.people)
        Scene: \(metadata.scene)
        Mood: \(metadata.mood)

        Write it like a journal memory.
        """
    }
    

    /// Check if API key is available
    var isAPIKeyAvailable: Bool {
        return !apiKey.isEmpty
    }
    
    /// Securely store API key in Keychain
    func storeAPIKeyInKeychain(_ key: String) -> Bool {
        let success = KeychainHelper.shared.store(key: "OpenAIAPIKey", value: key)
        if success {
            print("✅ API key stored securely in Keychain")
        } else {
            print("❌ Failed to store API key in Keychain")
        }
        return success
    }
    
    /// Remove API key from Keychain
    func removeAPIKeyFromKeychain() -> Bool {
        let success = KeychainHelper.shared.delete(key: "OpenAIAPIKey")
        if success {
            print("✅ API key removed from Keychain")
        } else {
            print("❌ Failed to remove API key from Keychain")
        }
        return success
    }
    
    /// Generate journal using custom prompt
    func generateJournalEntry(prompt: String, completion: @escaping (String?) -> Void) {
        guard isAPIKeyAvailable else {
            print("❌ OpenAI API key not available")
            completion(nil)
            return
        }
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You're a poetic travel journal assistant. Keep entries short, visual, and emotional."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to encode JSON body: \(error.localizedDescription)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let data = data else {
                print("❌ No data returned from OpenAI")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw response from OpenAI:\n\(raw)")
            }

            do {
                if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = result["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    print("❌ Unexpected response format")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func suggestNextDestination(from journalText: String, currentRegion: String, completion: @escaping (String?) -> Void) {
        let prompt = """
        Based on the following journal entry from a trip to \(currentRegion), suggest a new travel destination that matches the mood, interests, or emotional tone of this experience. Explain why it fits.

        JOURNAL:
        \"\"\"
        \(journalText)
        \"\"\"
        """

        generateJournalEntry(prompt: prompt, completion: completion)
    }
    
    func generateEnrichedJournalEntry(from metadata: MediaMetadataSummary, completion: @escaping (String?) -> Void) {
        let prompt = """
        Write a warm, emotional, short travel journal entry as if I’m recalling this memory. Use vivid sensory language. Mention the location, time of day, people present, what we were doing, and how it felt.

        Metadata:
        Location: \(metadata.location)
        Date: \(metadata.date)
        People: \(metadata.people)
        Scene: \(metadata.scene)
        Mood: \(metadata.mood)
        """

        generateJournalEntry(prompt: prompt, completion: completion)
    }


}
