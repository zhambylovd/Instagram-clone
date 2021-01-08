//
//  Post.swift
//  Instagram Clone
//
//  Created by morua on 1/8/21.
//  Copyright © 2021 morua. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
