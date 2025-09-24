import Foundation
import UIKit
import Vision
import CoreML

class ObjectRecognizer {
    static func detectObjects(in image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        // 1. Load model
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            print("❌ Failed to load MobileNetV2")
            completion([])
            return
        }

        // 2. Create a CoreML request
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }

            let labels = results
                .filter { $0.confidence > 0.1 }
                .prefix(5)
                .map { $0.identifier }

            completion(labels)
        }

        // 3. Run handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
