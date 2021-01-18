//
//  CommentsController.swift
//  Instagram Clone
//
//  Created by morua on 1/11/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: BaseListController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {

    // MARK: - Properties
    var post: Post?
    var comments: [Comment] = []
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    let cellId = "cellId"
    
    // MARK: - Override properties
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
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
    
    // MARK: - Fetch comments
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
    
    // MARK: - show, hide tabBar
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
    
    // MARK: - Collection view methods
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
    
    // MARK: - CommentInputAccessoryViewDelegate
    func didSubmit(for comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let postId = post?.id else { return }
        
        let values = [
            "uid": uid,
            "text": comment,
            "creationDate": Date().timeIntervalSince1970
            ] as [String : Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Failed to insert comment to database: \(error)")
                return
            }
            
            print("Successfully inserted comment to database")
            
            self.containerView.clearCommentTextField()
        }
    }
    
}
