//
//  Post.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import Foundation

struct Post {
    var postId: String?
    
    let imageUrl: String
    let user: User
    let caption: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
