//
//  SearchCell.swift
//  Instagram Clone
//
//  Created by morua on 1/10/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(usernameLabel )
    
        profileImageView.centerYInSuperview()
        profileImageView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        
        usernameLabel.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 0))
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, leading: usernameLabel.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}