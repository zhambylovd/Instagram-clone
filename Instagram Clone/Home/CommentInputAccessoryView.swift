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

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    
    // MARK: - Properties
    var delegate: CommentInputAccessoryViewDelegate?
    
    fileprivate let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    fileprivate let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Text Comment"
        tv.textColor = UIColor.lightGray
        tv.isScrollEnabled = false
        tv.font = .systemFont(ofSize: 18)
        return tv
    }()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textView.delegate = self
        
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        addSubview(submitButton)
        addSubview(textView)
        
        submitButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 12), size: .init(width: 50, height: 50))
        
        textView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: submitButton.leadingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 0))
        
        setupLineSeparatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Some methods
    func clearCommentTextField() {
        textView.text = nil
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        
        lineSeparatorView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    // MARK: - Action functions
    @objc func handleSubmit() {
        guard let comment = textView.text else { return }
        
        delegate?.didSubmit(for: comment)
    }
}
