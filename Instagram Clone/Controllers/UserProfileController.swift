//
//  UserProfileController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: BaseListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let username = dictionary["username"] as? String
            self.navigationItem.title = username
        }) { error in
            print("Failed to fetch user: \(error)")
        }
    }
    
}
