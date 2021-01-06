//
//  ViewController.swift
//  Instagram Clone
//
//  Created by morua on 1/6/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "plus_photo")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        field.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return field
    }()
    
    let usernameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "User Name"
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        field.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        field.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return field
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, !email.isEmpty,
            let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, password.count >= 6 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else { return }
            
            guard let result = result, error == nil else {
                print("Failed to create user: \(String(describing: error))")
                return
            }
            
            print("Successfully created user: \(result.user.uid)")
             
            guard let image = self.plusPhotoButton.imageView?.image,
                let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
//            FirebaseStorage.Storage.storage().reference().child("profile_picture").putData(uploadData, metadata: nil) { (metadata, error) in
//
//                if let error = error {
//                    print("Failed to upload profile image: \(error)")
//                    return
//                }
//
//                let profileImageUrl = metadata.
//
//                print("Successfully upload profile image")
//            }
            
            let storageRef = Storage.storage().reference().child("profile_images")
            
            let filename = UUID().uuidString
            let riversRef = storageRef.child(filename)
            
            riversRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata, error == nil else {
                    print("Failed to upload profile image: \(String(describing: error))")
                    return
                }
                
                riversRef.downloadURL { (url, error) in
                    guard let url = url, error == nil else {
                        print("Failed to download url: \(String(describing: error))")
                        return
                    }
                    
                    let urlString = url.absoluteString
                    
                    let dictionaryValues = [
                        "username": username,
                        "profile_image": urlString
                    ]
                    
                    let values = [result.user.uid: dictionaryValues]

                    FirebaseDatabase.Database.database().reference().child("users").updateChildValues(values) { (error, ref) in
                        if let error = error {
                            print("Failed to save user info into database: \(error)")
                            return
                        }

                        print("Successfully saved user info to database")
                    }
                }
                
                print("Successfully upload profile image to storage")
            }
        }
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = !(emailTextField.text?.isEmpty ?? false) &&
            !(usernameTextField.text?.isEmpty ?? false) &&
            passwordTextField.text?.count ?? 0 >= 6
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .link
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: view.frame.height/5, left: 0, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        plusPhotoButton.centerXInSuperview()
        
        setupInputFields()
        
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 200))
    }
}
