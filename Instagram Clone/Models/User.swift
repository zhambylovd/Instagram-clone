//
//  User.swift
//  Instagram Clone
//
//  Created by morua on 1/9/21.
//  Copyright © 2021 morua. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profile_image"] as? String ?? ""
    }
}
