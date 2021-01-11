//
//  CommentsController.swift
//  Instagram Clone
//
//  Created by morua on 1/11/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: BaseListController {
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar()
    }
    
    func hideTabBar() {
        var frame = self.tabBarController?.tabBar.frame
        frame!.origin.y = self.view.frame.size.height + (frame?.size.height)!
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = frame!
        })
    }

    func showTabBar() {
        var frame = self.tabBarController?.tabBar.frame
        frame!.origin.y = self.view.frame.size.height - (frame?.size.height)!
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = frame!
        })
    }
    
    @objc func handleSubmit() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let text = commentTextField.text,
            let postId = post?.postId else { return }
        
        let values = [
            "uid": uid,
            "text": text,
            "creationDate": Date().timeIntervalSince1970
            ] as [String : Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Failed to insert comment to database: \(error)")
                return
            }
            
            print("Successfully inserted comment to database")
        }
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        containerView.addSubview(commentTextField)
        containerView.addSubview(submitButton)
        
        commentTextField.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: submitButton.leadingAnchor, padding: .init(top: 0, left: 12, bottom: 0, right: 0))
        
        submitButton.anchor(top: containerView.topAnchor, leading: nil, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 12), size: .init(width: 50, height: 0))
        
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment"
        return tf
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
