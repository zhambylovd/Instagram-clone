//
//  CommentInputAccessoryView.swift
//  Instagram Clone
//
//  Created by morua on 1/15/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    fileprivate let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    fileprivate let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment"
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(submitButton)
        addSubview(commentTextField)
        
        submitButton.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 12), size: .init(width: 50, height: 0))
        
        commentTextField.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: submitButton.leadingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 0))
        
        setupLineSeparatorView()
    }
    
    func clearCommentTextField() {
        commentTextField.text = nil
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        
        lineSeparatorView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    @objc func handleSubmit() {
        guard let comment = commentTextField.text else { return }
        
        delegate?.didSubmit(for: comment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
