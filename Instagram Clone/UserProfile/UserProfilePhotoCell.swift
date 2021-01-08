//
//  UserProfilePhotoCell.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post! {
        didSet {
            guard let url = URL(string: post.imageUrl) else { return }

            URLSession.shared.dataTask(with: url) { [weak self] (data, resp, err) in
                guard let self = self else { return }

                guard let data = data, err == nil else {
                    print("Failed to fetch image data: \(err)")
                    return
                }

                let image = UIImage(data: data)

                DispatchQueue.main.async {
                    self.photoImageView.image = image
                }
            }.resume()
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
