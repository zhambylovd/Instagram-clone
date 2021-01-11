//
//  CustomImageView.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

var imageCache: [String: UIImage] = [:]

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, resp, err) in
            guard let self = self else { return }

            guard let data = data, err == nil else {
                print("Failed to fetch image data: \(String(describing: err))")
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }

            let image = UIImage(data: data)
            
            imageCache[url.absoluteString] = image

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
