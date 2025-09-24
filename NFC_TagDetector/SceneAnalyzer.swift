

import Foundation
import Vision
import UIKit
import Photos

class SceneAnalyzer {
    static func classifyScene(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNClassifyImageRequest { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }

            completion(topResult.identifier) // e.g. "cityscape"
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Vision error: \(error)")
                completion(nil)
            }
        }
    }
}
