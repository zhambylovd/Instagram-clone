//
//  PreviewPhotoContainerView.swift
//  Instagram Clone
//
//  Created by morua on 1/11/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
        
        guard let previewImage = previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { [weak self] (success, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to save image to photo library: \(error)")
                return
            }
            
            print("Successfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = .boldSystemFont(ofSize: 18)
                savedLabel.textAlignment = .center
                savedLabel.textColor = .white
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.numberOfLines = 0
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }) { completed in
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }) { _ in
                        savedLabel.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.fillSuperview()
        
        cancelButton.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        
        saveButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 24, bottom: 24, right: 0), size: .init(width: 50, height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
