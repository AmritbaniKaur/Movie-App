//
//  SignUpViewCollection.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/10/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit

class SignUpViewCollection: UIView
{
    var submitAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    var uploadImageAction: (() -> Void)?

    let containerView = UIView(frame: CGRect(x:0,y:0,width:320,height:500))

    let backgroundImageView: UIImageView =
    {
        let img = UIImageView()
        img.image = UIImage(named: "Movie_3_copy_blur")
        img.contentMode = .scaleToFill
        return img
    }()
    
    let nameTextField: UITextField =
    {
        let tf = UITextField(title: "Name", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        return tf
    }()
    
    let emailTextField: UITextField =
    {
        let tf = UITextField(title: "Email", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        return tf
    }()
    
    let passwordTextField: UITextField =
    {
        let tf = UITextField(title: "Password", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        return tf
    }()
    
    let confirmPasswordTextField: UITextField =
    {
        let tf = UITextField(title: "Confirm Password", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        return tf
    }()

    let profileImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default-user-image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadProfileImage)))
        //imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let submitButton: UIButton =
    {
        let button = UIButton(title: "Submit", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        return button
    }()
    
    let cancelButton: UIButton =
    {
        let button = UIButton(title: "Cancel", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews()
    {
        if let image = UIImage(named: "default-user-image")
        {
            let ratio = image.size.width / image.size.height
            if containerView.frame.width > containerView.frame.height
            {
                let newHeight = containerView.frame.width / ratio
                profileImageView.frame.size = CGSize(width: containerView.frame.width, height: newHeight)
            }
            else
            {
                let newWidth = containerView.frame.height * ratio
                profileImageView.frame.size = CGSize(width: newWidth, height: containerView.frame.height)
            }
        }
                
        let stackView = createStackView(views: [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, submitButton, cancelButton])

        self.addSubview(backgroundImageView)
        self.addSubview(profileImageView)
        self.addSubview(stackView)
        
        backgroundImageView.setAnchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)

        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        stackView.setAnchor(width: self.frame.width - 60, height: 290)
        stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 210).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        //stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadProfileImage)))
        profileImageView.isUserInteractionEnabled = true
    }

    @objc func handleUploadProfileImage()
    {
        uploadImageAction?()
    }
    
    @objc func handleSubmit()
    {
        submitAction?()
    }
    
    @objc func handleCancel()
    {
        cancelAction?()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
