//
//  CustomImageView.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        print("Loading image...")
        lastURLUsedToLoadImage = urlString
        
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

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
