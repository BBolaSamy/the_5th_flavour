
import Foundation
import Vision
import UIKit

struct DetectedFace: Identifiable {
    let id = UUID()
    let image: UIImage
    var name: String? = nil
    let boundingBox: CGRect
}

class FaceDetectionService {
    static func detectFaces(in image: UIImage, completion: @escaping ([DetectedFace]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation], error == nil else {
                completion([])
                return
            }

            let faces: [DetectedFace] = results.compactMap { observation in
                let boundingBox = observation.boundingBox
                let convertedRect = convertBoundingBox(boundingBox, in: image.size)
                guard let cropped = image.cgImage?.cropping(to: convertedRect) else {
                    return nil
                }
                let faceImage = UIImage(cgImage: cropped)
                return DetectedFace(image: faceImage, boundingBox: convertedRect)
            }

            completion(faces)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private static func convertBoundingBox(_ boundingBox: CGRect, in imageSize: CGSize) -> CGRect {
        let width = boundingBox.width * imageSize.width
        let height = boundingBox.height * imageSize.height
        let x = boundingBox.minX * imageSize.width
        let y = (1 - boundingBox.maxY) * imageSize.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
