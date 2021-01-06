//
//  ViewController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "plus_photo")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        return field
    }()
    
    let userNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "User Name"
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        return field
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 5
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: view.frame.height/5, left: 0, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        plusPhotoButton.centerXInSuperview()
        
        setupInputFields()
        
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, userNameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 200))
    }
}

