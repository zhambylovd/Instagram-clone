//
//  User.swift
//  Instagram Clone
//
//  Created by morua on 1/9/21.
//  Copyright © 2021 morua. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profile_image"] as? String ?? ""
    }
}
