//
//  LoginViewController.swift
//  Instagram Clone
//
//  Created by morua on 1/7/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account?  Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 40, right: 0), size: .init(width: 0, height: 50))
    }
    
    @objc func handleShowSignUp() {
        let vc = SignUpController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
