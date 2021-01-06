//
//  BaseListController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class BaseListController: UICollectionViewController {
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
