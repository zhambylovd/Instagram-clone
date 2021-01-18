//
//  SharePhotoController.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    // MARK: - Static properties
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    // MARK: - Properties
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        return tv
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    // MARK: - Image and text views
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 100 ))
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: 84, height: 0))
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 0, left: 4, bottom: 0, right: 0))
    }
    
    // MARK: - Save to Database
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String, postImage: UIImage, caption: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = [
            "imageUrl": imageUrl,
            "caption": caption,
            "imageWidth": postImage.size.width,
            "imageHeight": postImage.size.height,
            "creationDate": Date().timeIntervalSince1970
            ] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to database: \(err)")
                return
            }
            
            print("Successfully save post to database")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    // MARK: - Action functions
    @objc func handleShare() {
        guard let caption = textView.text, !caption.isEmpty,
            let image = selectedImage,
            let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts")
        let riversRef = storageRef.child(filename)
        
        riversRef.putData(uploadData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image: \(error)")
                return
            }
            
            riversRef.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("Failed to download url: \(String(describing: error))")
                    return
                }
                
                let urlString = url.absoluteString
                print("Successfully uploaded post image: \(urlString)")
                
                self.saveToDatabaseWithImageUrl(imageUrl: urlString, postImage: image, caption: caption)
            }
        }
    }
}
