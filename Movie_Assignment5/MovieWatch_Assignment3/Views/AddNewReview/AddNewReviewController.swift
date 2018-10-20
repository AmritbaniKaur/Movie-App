//
//  AddNewReviewController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/13/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

class AddNewReviewController: UIViewController
{
    var defaults = UserDefaults.standard
    var ref: DatabaseReference!
    var addReviewView : AddNewReviewsCellCollection!
    //var revId: String?
    let backgroundImageView = UIImageView()
    let userId = Auth.auth().currentUser?.uid
    let userName = Auth.auth().currentUser?.displayName
    //var isLikeImage = 0
    
    var currentMovie: MovieAttrInfo? // Data we will use
    {
        didSet
        {
            let id = currentMovie?.id
        }
    }
    
    var appUser: AppUser?
    {
        didSet
        {
            //print("Value Set")
            //guard let username = appUser?.username else { return }
            //guard let profileurl = appUser?.profileurl else { return }
            
            //setupNavBarItems()
            //navigationItem.title = username
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("\n\n Movie Id in AddReview: ", self.currentMovie!.id!)
        
        ref = Database.database().reference()
        navigationItem.title = "Add your Review"
        
        view.backgroundColor = UIColor.brown
        
        setupViews()

        ///////////////////////////////////////////////////////////
        // Not working
        //backgroundImageView.image = UIImage(named: "Movie_5")
        //backgroundImageView.contentMode = .scaleToFill

        //self.view.addSubview(backgroundImageView)
        //view.backgroundColor = UIColor.green
        // Do any additional setup after loading the view.
    }

    
    private func setupNavBarItems()
    {
        guard let username = appUser?.username else { return }
        print("Username in Add Review: ", username)
        
        let titleView = UIButton() //UIView()
        titleView.frame = CGRect(x:0, y:0, width:100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = appUser?.profileurl{
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = appUser?.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        titleView.addTarget(self, action: #selector(handleUserInfo), for: .touchUpInside)
        
        self.navigationItem.titleView = titleView
    }
    
    @objc func handleUserInfo()
    {
        print("Edit User Info!")
        let editUserInfoController = UINavigationController(rootViewController: UserInfoController())
        present(editUserInfoController, animated: true, completion: nil)
        
    }
    
    func setupViews()
    {
        let addReviewView = AddNewReviewsCellCollection(frame: self.view.frame)
        self.addReviewView = addReviewView
        self.addReviewView.submitAction = submitPressed
        self.addReviewView.cancelAction = cancelPressed
        //self.addReviewView.likeDislikeAction = toggleLikeDislike
        
        view.addSubview(addReviewView)
        addReviewView.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }

    @objc func toggleLikeDislike()
    {
        // code to toggle and display the change
        
    }
    
    @objc func submitPressed()
    {
        print("Submit Button Pressed!")
        
        let revId = UUID().uuidString
        
        guard let title = addReviewView.titleReviewTextField.text else { return }
        guard let content = addReviewView.reviewContentTextField.text else { return }
        //guard let isLike = addReviewView.isLike else { return }
        
        let movieId = String(describing: self.currentMovie!.id!)
        print("\n\n userId! in submitPressed", userId!)
        print("\n For Movie Id: ", movieId)
        
        //guard let uId = Auth.auth().currentUser?.uid else { return }
        //ref.child("users").child(userId!).observeSingleEvent(of: .value) { (snapshot) in
        ref.child("users").child(userId!).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let usrnm = data["username"] as? String else { return }
        
        print("Review Id: ", revId)
        print("title: ", title)
        print("content: ", content)
        //print("isLike: ", isLike)
        print("Username: ", usrnm)
        //print("appUser?.username: ", appUser?.username!)
        
        let reviewData: [String: Any] = [
            "reviewId" : revId,
            "reviewtitle" : title,
            "reviewcontent" : content,
            //"isLike" : isLike,    // Neutral: 0, Like: 1, Dislike: 2
            "userName" : usrnm,
            "userId" : self.userId,
            "noOfLikes" : 0,
            "noOfDislikes" : 0
        ]

        let dbRef = Database.database().reference(fromURL: "https://movieapp-91715.firebaseio.com/")
        
            let reviewReference = dbRef.child("reviews").child(movieId).child(self.userId!) //child("\(currentMovie?.id)").child(userId!)
            reviewReference.updateChildValues(reviewData, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
            
            //let goBackDetailView = UINavigationController(rootViewController: DetailViewController())
            //self.present(goBackDetailView, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            //self.myTopListViewController?.fetchUserAndSetupNavBarTitle()
            //self.myTopListViewController?.navigationController?.popViewController(animated: true)
        })
        }
    }
    
    func cancelPressed()
    {
        dismiss(animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITextView
{
    public convenience init(title: String, borderColor: UIColor)
    {
        self.init()
        
        //self.borderStyle = .none
        self.layer.cornerRadius = 5
        //self.backgroundColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 0.5)
        self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        //self.borderStyle = UITextBorderStyle.roundedRect // .bezel
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        self.textColor = UIColor(white: 1, alpha: 1)
        self.font = UIFont.systemFont(ofSize: 18)
        self.backgroundColor = .clear
        self.autocorrectionType = .no
        // placeholder
        //var placeholder = NSMutableAttributedString()
        //placeholder = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white:1, alpha:0.7)]))
        //self.attributedPlaceholder = placeholder
        self.setAnchor(width: 0, height: 40)
        //self.setLeftPaddingPoints(15)
    }
}
