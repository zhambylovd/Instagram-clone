//
//  MainTabBarController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            createNavController(viewController: UserProfileController(), imageName: "profile_unselected", selectedImageName: "profile_selected"),
            createNavController(viewController: UIViewController(), imageName: "apps", selectedImageName: ""),
            createNavController(viewController: UIViewController(), imageName: "search", selectedImageName: "")
        ]
    }
    
    fileprivate func createNavController(viewController: UIViewController, imageName: String, selectedImageName: String) -> UIViewController {
        
        viewController.view.backgroundColor = .white
        viewController.navigationItem.title = title
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        navController.tabBarItem.selectedImage = UIImage(named: selectedImageName)
        
        tabBar.tintColor = .black
        
        return navController
    }
    
}