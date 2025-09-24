//
//  eee.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 29.05.25.
//

import Foundation

class UnsplashImageFetcher {
    static let apiKey = "YOUR_UNSPLASH_ACCESS_KEY" // Replace with your actual key

    static func fetchImageURL(for query: String, completion: @escaping (URL?) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.unsplash.com/search/photos?page=1&query=\(encodedQuery)&client_id=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = result["results"] as? [[String: Any]],
                  let first = results.first,
                  let urls = first["urls"] as? [String: String],
                  let imageUrlString = urls["regular"],
                  let imageURL = URL(string: imageUrlString) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            DispatchQueue.main.async { completion(imageURL) }
        }.resume()
    }
}
