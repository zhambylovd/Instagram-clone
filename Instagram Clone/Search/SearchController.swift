//
//  SearchController.swift
//  Instagram Clone
//
//  Created by morua on 1/10/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class SearchController: BaseListController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    // MARK: - Properties
    var users: [User] = []
    var filteredUsers: [User] = []
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    let cellId = "cellId"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        setupSearchBar()
        fetchUsers()
    }
    
    // MARK: - Fetch users
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            }
            
            self.users.sort { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            }
            
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        }) { error in
            print("Failed to fetch users for search: \(error)")
        }
    }
    
    // MARK: - Search users
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { user -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK: - Collection view methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        
        cell.user = filteredUsers [indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        
        searchController.searchBar.resignFirstResponder()
        
        let vc = UserProfileController()
        vc.userId = user.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 66)
    }
}
