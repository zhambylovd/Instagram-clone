//
//  FirebaseUtils.swift
//  Instagram Clone
//
//  Created by morua on 1/9/21.
//  Copyright © 2021 morua. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }

            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)

        }) { error in
            print("Failed to fetch user for posts: \(error)")
        }
    }
}
