//
//  HomePostCell.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    // MARK: - Properties
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let urlString = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: urlString)
            
            usernameLabel.text = post?.user.username
            
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.loadImage(urlString: profileImageUrl)
            
            let selectedLikeImage = UIImage(named: "like_selected")?.withRenderingMode(.alwaysOriginal)
            let unselectedLikeImage = UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal)
            likeButton.setImage(post?.hasLiked == true ? selectedLikeImage : unselectedLikeImage, for: .normal)
            
            setupAttributedCaption()
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.constrainWidth(constant: 40)
        iv.constrainHeight(constant: 40)
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.constrainWidth(constant: 44)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.constrainWidth(constant: 40)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.constrainWidth(constant: 40)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.constrainWidth(constant: 40)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.constrainWidth(constant: 40)
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(arrangedSubviews: [userProfileImageView, usernameLabel, UIView(), optionsButton])
        stackView.spacing = 8

        
        addSubview(photoImageView)
        addSubview(stackView)
        addSubview(captionLabel)
        
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8))
        
        photoImageView.anchor(top: stackView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: frame.width))
        
        setupActionButtons()
        
        captionLabel.anchor(top: likeButton.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     // MARK: - Fileprivate functions
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton, UIView(), bookmarkButton])
        stackView.spacing = 5
        
        addSubview(stackView)
        
        stackView.anchor(top: photoImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 50))
    }
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        captionLabel.attributedText = attributedText
    }
    
    // MARK: - Action functions
    @objc func handleComment() {
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
}
