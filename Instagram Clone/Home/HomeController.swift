//
//  HomeController.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class HomeController: BaseListController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    // MARK: - Properties
    let cellId = "cellId"
    
    var posts: [Post] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView.backgroundColor = .white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()
    }
    
    // MARK: - Fetch posts and user ids
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach { (key, value) in
                Database.fetchUserWithUID(uid: key) { [weak self] user in
                    guard let self = self else { return }
                    
                    self.fetchPostWithUser(user: user)
                }
            }
        }) { error in
            print("Failed to fetch following users: \(error)")
        }
    }
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { [weak self] user in
            guard let self = self else { return }
            self.fetchPostWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let ref = Database.database().reference().child("likes").child(key).child(uid)
                
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    }
                    self.collectionView.reloadData()
                }) { error in
                    print("Failed to fetch like info for post: \(error)")
                }
            }
        }) { error in
            print("Failed to fetch posts: \(error)")
        }
    }
    
    // MARK: - Navigation items
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    // MARK: - Action functions
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    
    @objc func handleRefresh() {
        print("Refreshing...")
        posts.removeAll()
        fetchAllPosts()
    }
    
    @objc func handleCamera() {
        let vc = CameraController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Collection view methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell 
        
        cell.post = posts[indexPath.item]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height: CGFloat = view.frame.width + 166        
        return .init(width: view.frame.width, height: height)
    }
    
    // MARK: - HomePostCellDelegate
    func didTapComment(post: Post) {
        let vc = CommentsController()
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var post = posts[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("likes").child(postId)
        let values = [uid: post.hasLiked == true ? 0 : 1]
        
        ref.updateChildValues(values) { [weak self] (error, _) in
            guard let self = self else { return  }
            
            if let error = error {
                print("Failed to insert like to database: \(error)")
                return
            }
            
            print("Successfully inserted like to database")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
}
