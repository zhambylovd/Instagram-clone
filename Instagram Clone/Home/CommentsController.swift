//
//  CommentsController.swift
//  Instagram Clone
//
//  Created by morua on 1/11/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: BaseListController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    var comments: [Comment] = []
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        
        let ref = Database.database().reference().child("comments").child(postId)
        
        ref.observe(.childAdded, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let dictionary = snapshot.value as? [String: Any],
                let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid) { [weak self] user in
                guard let self = self else { return }
                
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }) { error in
            print("Failed to fetch comments: \(error)")
        }
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
            let postId = post?.id else { return }
        
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
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        
        lineSeparatorView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, size: .init(width: 0, height: 0.5))
        
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
