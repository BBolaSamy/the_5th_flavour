

import Foundation
import Vision
import UIKit

class PersonDetector {
    static func detectFaces(in image: UIImage, completion: @escaping (Int) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(0)
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation] else {
                completion(0)
                return
            }

            completion(results.count)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Face detection error: \(error)")
                completion(0)
            }
        }
    }
}
