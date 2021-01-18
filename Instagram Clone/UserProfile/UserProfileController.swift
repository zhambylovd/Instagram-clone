//
//  UserProfileController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: BaseListController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    // MARK: - Properties
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    let headerId = "headerId"
    
    var user: User?
    var userId: String?
    var posts: [Post] = []
    var isGridView = true
    var isFinishedPaging = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
    }
    
    // MARK: - Pagination
    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else { return }
        
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            guard let user = self.user else { return }
            
            allObjects.reverse()
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            allObjects.forEach({ snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                var post = Post(user: user , dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            })
            
            self.collectionView.reloadData()
        }) { error in
            print("Failed to paginate for posts: \(error)")
        }
    }
    
    // MARK: - Fetch user
    fileprivate func fetchUser() {
        
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        
        let uid = userId ?? currentUserUID
        
        Database.fetchUserWithUID(uid: uid) { [weak self] user in
            guard let self = self else { return }
            
            self.user = user
            self.navigationItem.title = self.user?.username
            
            self.collectionView?.reloadData()
            
            self.paginatePosts()
        }
    }
    
    // MARK: - Log Out
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let vc = LoginController()
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Collection view methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            let height: CGFloat = view.frame.width + 166
            return .init(width: view.frame.width, height: height)
        }
    }
    
    // MARK: - Header methods
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        header.delegate = self

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // MARK: - UserProfileHeaderDelegate
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
}


