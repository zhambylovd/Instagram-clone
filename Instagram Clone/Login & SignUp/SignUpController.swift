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
import JGProgressHUD

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    private let spinner = JGProgressHUD(style: .dark)
    
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
        field.returnKeyType = .continue
        return field
    }()
    
    let usernameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "User Name"
        field.backgroundColor = UIColor(white: 0, alpha: 0.03)
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 14)
        field.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        field.returnKeyType = .continue
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
        field.returnKeyType = .go
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
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.setTitle("Don't have an account?  Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        view.addSubview(plusPhotoButton)
        view.addSubview(alreadyHaveAccountButton)
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        plusPhotoButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: view.frame.height/5, left: 0, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        plusPhotoButton.centerXInSuperview()
        
        alreadyHaveAccountButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 40, right: 0),size: .init(width: 0, height: 50))
        
        setupInputFields()
    }
    
    // MARK: - Fileprivate functions
    fileprivate func alertSignUpError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        present(alert, animated: true)
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
    
    // MARK: - Sign Up
    @objc func handleSignUp() {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, !email.isEmpty,
            let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, password.count >= 6 else { return }
        
        spinner.show(in: view)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard let result = result, error == nil else {
                self.emailTextField.text = nil
                self.usernameTextField.text = nil
                self.passwordTextField.text = nil
                
                guard let message = error?.localizedDescription else { return }
                self.alertSignUpError(message: message)
                print("Failed to create user: \(String(describing: error))")
                return
            }
            
            print("Successfully created user: \(result.user.uid)")
             
            guard let image = self.plusPhotoButton.imageView?.image,
                let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let storageRef = Storage.storage().reference().child("profile_images")
            
            let filename = UUID().uuidString
            let riversRef = storageRef.child(filename)
            
            riversRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    print("Failed to upload profile image: \(String(describing: error))")
                    return
                }
                
                print("Successfully upload profile image to storage")
                
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
                    
                    self.saveToDatabaseUserInfo(values: values)
                }
            }
        }
    }
    
    fileprivate func saveToDatabaseUserInfo(values: [String: Any]) {
        FirebaseDatabase.Database.database().reference().child("users").updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Failed to save user info into database: \(error)")
                return
            }

            print("Successfully saved user info to database")
            
            if #available(iOS 13.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                guard let mainTabBarController = keyWindow?.rootViewController as? MainTabBarController else { return }
                
                mainTabBarController.setupViewControllers()
            } else {
                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                
                mainTabBarController.setupViewControllers()
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Action functions
    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = !(emailTextField.text?.isEmpty ?? false) &&
            !(usernameTextField.text?.isEmpty ?? false) &&
            passwordTextField.text?.count ?? 0 >= 6
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
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
    
    // MARK: - UIImagePickerControllerDelegate
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            handleSignUp()
        }
        return true
    }
}
