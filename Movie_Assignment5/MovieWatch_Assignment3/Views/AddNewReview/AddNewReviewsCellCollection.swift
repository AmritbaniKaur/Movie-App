//
//  AddNewReviewsCellCollection.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/13/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit

class AddNewReviewsCellCollection: UIView
{
    var submitAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    //var likeDislikeAction: (() -> Void)?
    //var isLike: Int?
    
    let containerView = UIView(frame: CGRect(x:0,y:0,width:320,height:500))

    let backgroundImageView: UIImageView =
    {
        let img = UIImageView()
        img.image = UIImage(named: "Movie_5")
        img.contentMode = .scaleToFill
        return img
    }()
    
    let titleReviewTextField: UITextField =
    {
        let titleText = UITextField(title: "Title", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        return titleText
    }()
    
    let reviewContentTextField: UITextView =
    {
        let contentText = UITextView(frame: CGRect(x:0, y:0, width: 320, height: 500))
        contentText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return contentText
    }()
    /*
    let reviewContentTextField: UITextField =
    {
        //let containerView = UIView(frame: CGRect(x:0,y:0,width:320,height:500))
        let contentText = UITextField(title: "Write a Review", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.35))
        //contentText.frame.size.height = 500
        //contentText.setAnchor(width: 50, height: 60)
        //contentText.widthAnchor.constraint(equalToConstant: 50).isActive = true
        contentText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return contentText
    }()
    */
    /*
    let likeDislikeView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Neutral")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadProfileImage)))
        //imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    */
    let submitButton: UIButton =
    {
        let button = UIButton(title: "Submit", borderColor: UIColor(red: 60/255, green: 10/255, blue: 115/255, alpha: 0.6))
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
        //isLike = 0

        //likeDislikeView.frame.size = CGSize(width: 50, height: 50)
 
        let stackView = createStackView(views: [titleReviewTextField, reviewContentTextField, submitButton, cancelButton])
        
        self.addSubview(backgroundImageView)
        //self.addSubview(likeDislikeView)
        self.addSubview(stackView)
        
        backgroundImageView.setAnchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        /*
        likeDislikeView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        likeDislikeView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        likeDislikeView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        likeDislikeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        */
        stackView.setAnchor(width: self.frame.width - 120, height: 290)
        stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        /*
        likeDislikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikeDislike)))
        likeDislikeView.isUserInteractionEnabled = true
         */
    }
    
    @objc func handleSubmit()
    {
        submitAction?()
    }
    
    @objc func handleCancel()
    {
        cancelAction?()
    }
    
    /*
    @objc func handleLikeDislike()
    {
        likeDislikeAction?()
    }
    */
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
