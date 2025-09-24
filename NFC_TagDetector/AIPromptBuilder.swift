

import Foundation
import Photos

class AIPromptBuilder {
    static func buildPrompt(for mediaItem: MediaItem, regionName: String, tone: String = "funny") -> String {
        let objects = mediaItem.detectedObjects.joined(separator: ", ")
        let creationDate = mediaItem.asset.creationDate ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL" // Full month name
        let month = dateFormatter.string(from: creationDate)

        let hour = Calendar.current.component(.hour, from: creationDate)
        let timeOfDay: String
        switch hour {
        case 6..<11: timeOfDay = "morning"
        case 11..<17: timeOfDay = "afternoon"
        case 17..<21: timeOfDay = "evening"
        default: timeOfDay = "night"
        }

        // Template Prompt
        return """
        Generate a travel journal entry in a \(tone) tone.
        The photo was taken in \(regionName), during the \(timeOfDay) in \(month).
        Detected objects in the image: \(objects).
        Mention any of these if relevant. Keep the writing colorful and specific.
        """
    }
}
