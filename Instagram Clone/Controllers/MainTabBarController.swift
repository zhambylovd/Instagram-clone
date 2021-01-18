//
//  MainTabBarController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.delegate = self
        
        checkCurrentUser()
        setupViewControllers()
    }
    
    fileprivate func checkCurrentUser() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginController())
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: false, completion: nil)
            }
            return
        }
    }
    
    func setupViewControllers() {
        viewControllers = [
            createNavController(viewController: HomeController(), imageName: "home_unselected", selectedImageName: "home_selected"),
            createNavController(viewController: SearchController(), imageName: "search_unselected", selectedImageName: "search_selected"),
            createNavController(viewController: UIViewController(), imageName: "plus_unselected", selectedImageName: ""),
            createNavController(viewController: UIViewController(), imageName: "like_unselected", selectedImageName: "like_selected"),
            createNavController(viewController: UserProfileController(), imageName: "profile_unselected", selectedImageName: "profile_selected")
        ]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        }
    }
    
    fileprivate func createNavController(viewController: UIViewController, imageName: String, selectedImageName: String) -> UIViewController {
        
        viewController.view.backgroundColor = .white
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = UIImage(named: imageName)
        navController.tabBarItem.selectedImage = UIImage(named: selectedImageName)
        tabBar.tintColor = .black
        
        return navController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let navController = UINavigationController(rootViewController: PhotoSelectorController())
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}
