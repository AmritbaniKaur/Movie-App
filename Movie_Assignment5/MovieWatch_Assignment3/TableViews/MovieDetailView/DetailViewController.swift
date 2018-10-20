//
//  DetailViewController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 3/21/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UITableViewController //UIViewController //UICollectionViewController //UIViewController
{
    var movieResults: MovieAttrInfo? // Data we will use
    var rowCount = 100
    let def_rows = 6
    let defaults = UserDefaults.standard
    var ref: DatabaseReference!
    var appReview: AppReview?
    var reviewArray = [AppReview]()
    var revRef = Database.database().reference().child("reviews")
    
    var reviewTitleLabel : UILabel!
    var reviewContentLabel : UILabel!
    
    var review:AppReview!
    {
        didSet
        {
            reviewTitleLabel.text = review.reviewtitle
            reviewContentLabel.text = review.reviewcontent
        }
    }
    
    
    var movie: MovieInfo?
    {
        didSet
        {
            let id = movie?.id

            let link = "https://api.themoviedb.org/3/movie/" + String(id!) + "?api_key=2141436cc1d11d1aa9f276be95e352c4"
            
            downloadJSON(link: link)
            {
            // Download details of a selected movie with id
                let movie = self.movieResults //.belongs_to_collection![0]
                print("movie: ", movie)
                print("Name from MovieAttrInfo: ", movie?.original_title!)
            }
        }
    }
    

    var appUser: AppUser?
    {
        didSet
        {
            setupNavBarItems()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        navigationItem.title = "Movie Details"
        
        let logoutBtn = UIButton()
        logoutBtn.setImage(UIImage(named: "Logout.png"), for: .normal)
        //logoutBtn.frame = CGRect(x:350, y:0, width:20, height: 20)
        logoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        logoutBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        logoutBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let item1 = UIBarButtonItem()
        item1.customView = logoutBtn
        
        let addReviewBtn = UIButton()
        addReviewBtn.setImage(UIImage(named: "write-review.png"), for: .normal)
        //addReviewBtn.frame = CGRect(x:300, y:0, width:40, height: 40)
        //addReviewBtn.translatesAutoresizingMaskIntoConstraints = false
        addReviewBtn.addTarget(self, action: #selector(handleAddReview), for: .touchUpInside)
        addReviewBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addReviewBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let item2 = UIBarButtonItem()
        item2.customView = addReviewBtn
        
        navigationItem.rightBarButtonItems = [item1,item2]
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Review", style: .plain, target: self, action: #selector(handleAddReview))
        
        let tempImageView = UIImageView(image: UIImage(named: "Movie_5"))
        tempImageView.frame = self.tableView.frame
        self.tableView.backgroundView = tempImageView;
        self.tableView.allowsSelection = false
        
        // Dynamic Heights
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        fetchUserInfo()
        tableView.reloadData()
    }

    private func setupNavBarItems()
    {
        print("setup!!!!!!")
        guard let username = appUser?.username else { return }
        print("username from detailview: ", username)
        
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
    
    func fetchUserInfo()
    {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print("userId from fetchUserInfo: ", userId)
        
        ref.child("users").child(userId).observeSingleEvent(of: .value){ (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let username = data["username"] as? String else { return }
            guard let email = data["email"] as? String else { return }
            guard let profileurl = data["profileurl"] as? String else { return }
            
            print("data",data)
            print("username",username)
            print("email",email)
            print("profileurl",profileurl)

            self.appUser = AppUser(username: username, uid: userId, email: email, profileurl: profileurl)
        }
        
    }
    
    
    @objc func handleUserInfo()
    {
        print("Edit User Info!")
        let editUserInfoController = UINavigationController(rootViewController: UserInfoController())
        present(editUserInfoController, animated: true, completion: nil)

    }
    
    
    @objc func handleLogout()
    {
        print("Logged Out!")
        do{
            try Auth.auth().signOut()
            defaults.set(false, forKey: "UserIsLoggedIn")
            let loginController = UINavigationController(rootViewController: LoginController())
            present(loginController, animated: true, completion: nil)
        }
        catch let err {
            print(err.localizedDescription)
        }
        
    }
    
    @objc func handleAddReview()
    {
        print("Add a Review!")
        let addRevCont = AddNewReviewController()
        addRevCont.currentMovie = movieResults
        let addNewReview = UINavigationController(rootViewController: addRevCont)
        present(addNewReview, animated: true, completion: nil)
    }
    
    @objc func handleEditReview(sender: UIButton)
    {
        print("Edit Review")
        print("Auth.auth().currentUser?.uid: ", Auth.auth().currentUser?.uid)
        print("sender.accessibilityIdentifier: ", sender.accessibilityIdentifier)
        
        // Authenticate or show pop up
        if Auth.auth().currentUser?.uid == sender.accessibilityIdentifier// authorized
        {
            print("Edit a Review!")
            let addRevCont = AddNewReviewController()
            addRevCont.currentMovie = movieResults
            let addNewReview = UINavigationController(rootViewController: addRevCont)
            present(addNewReview, animated: true, completion: nil)
        }
        else // Show Alert
        {
            print("Not Authorized to edit!")
            
            let alertController = UIAlertController(title: "Not Authorized", message:
                "You cannot Edit Someone else's Review!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @objc func handleDeleteReview(sender: UIButton)
    {
        print("Delete Review")
        print("Auth.auth().currentUser?.uid: ", Auth.auth().currentUser?.uid)
        print("sender.accessibilityIdentifier: ", sender.accessibilityIdentifier)
        
        // Authenticate or show pop up
        if Auth.auth().currentUser?.uid == sender.accessibilityIdentifier// authorized
        {
            let tempMovieId = String(movie!.id!)
            let tempUID = Auth.auth().currentUser!.uid
            print("Delete a Review!")
            print("Movie Id: ", tempMovieId)
            print("User Id: ", tempUID)

            revRef.child(tempMovieId).child(tempUID).removeValue()
            self.reviewArray.removeAll()
            self.tableView.reloadData()
        }
        else // Show Alert
        {
            print("Not Authorized to Delete!")
            
            let alertController = UIAlertController(title: "Not Authorized", message:
                "You cannot Delete Someone else's Review!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func handleLikeReview(sender: UIButton)
    {
        ///let likeValue =
        let tempMovieId = String(movie!.id!)
        var likeValue = sender.tag
        let tempReviewUserId = sender.accessibilityIdentifier!
        print("tempMovieId: ", tempMovieId)
        print("likeValue: ", likeValue)
        print("tempReviewUserId: ", tempReviewUserId)
        let usersReference = revRef.child(tempMovieId).child(tempReviewUserId)

        // increment Like
        likeValue = likeValue + 1
        
        let values = ["noOfLikes": likeValue]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
        })
    }
    
    @objc func handleDislikeReview(sender: UIButton)
    {
        ///let likeValue =
        let tempMovieId = String(movie!.id!)
        var dislikeValue = sender.tag
        let tempReviewUserId = sender.accessibilityIdentifier!
        print("tempMovieId: ", tempMovieId)
        print("likeValue: ", dislikeValue)
        print("tempReviewUserId: ", tempReviewUserId)
        let usersReference = revRef.child(tempMovieId).child(tempReviewUserId)
        
        // increment Like
        dislikeValue = dislikeValue + 1
        
        let values = ["noOfDislikes": dislikeValue]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // download reviews
        let tempMovieId = String(describing: movie!.id!)
        print("Local Movie Id in ViewDidAppear: ", tempMovieId)
        revRef.child(tempMovieId).observe(.value, with: {(snapshot) in
            self.reviewArray.removeAll()

            for child in snapshot.children
            {
                let childSnapshot = child as! DataSnapshot
                let review = AppReview(snapshot: childSnapshot)
                print("review from new observe: ", review)
                self.reviewArray.insert(review, at: 0)
            }
            self.tableView.reloadData()
        })
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return rowCount
        return reviewArray.count + 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        //let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)

        cell.backgroundColor = .clear
        
        // Segregate the first 5 rows
        if indexPath.row == 0
        {
            //////////////////////////////////////////////////////////////////////
            // Movie Title
            
            let header = UILabel()
            header.shadowColor = UIColor.brown
            header.font = UIFont.boldSystemFont(ofSize: 22)
            header.textAlignment = NSTextAlignment.center
            header.sizeToFit()
            cell.contentView.addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            header.text = self.movieResults?.original_title

            let xCenterConstraint = NSLayoutConstraint(item: header, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: header, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else if indexPath.row == 1
        {
            //////////////////////////////////////////////////////////////////////
            // 5 Star Ratings
            
            let ratings = UIImageView()
            ratings.contentMode = .scaleAspectFit //.scaleAspectFill //.scaleAspectFit
            ratings.image = UIImage(named: "default-movie")?.withAlignmentRectInsets(UIEdgeInsets(top: -15, left: 0, bottom: -5, right: 0))
            ratings.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(ratings)
            ratings.translatesAutoresizingMaskIntoConstraints = false
            ratings.image = getImage()

            let xCenterConstraint = NSLayoutConstraint(item: ratings, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: ratings, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else if indexPath.row == 2
        {
            //////////////////////////////////////////////////////////////////////
            // Poster
            
            let poster = UIImageView()
            //let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            poster.image = UIImage(named: "default-movie")?.withAlignmentRectInsets(UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0))
            poster.contentMode = .scaleAspectFit
            poster.translatesAutoresizingMaskIntoConstraints = false

            //cell.setAnchor(width: 310, height: 210)
            cell.contentView.addSubview(poster)
            poster.translatesAutoresizingMaskIntoConstraints = false
            
            let path = self.movieResults?.backdrop_path
            var downloadedImage = ""
            if path != nil
            {
                downloadedImage = "https://image.tmdb.org/t/p/w342/" + String(path!)
                //let downloadedImage = "https://api.themoviedb.org/3/movie/337167/images?api_key=2141436cc1d11d1aa9f276be95e352c4" + movieId!
            }
            self.getImageFromWeb(downloadedImage) { (image) in
                if let image = image
                {
                    poster.image = image
                } // if you use an Else statement, it will be in background
            }
            poster.heightAnchor.constraint(equalToConstant: 180).isActive = true
            poster.widthAnchor.constraint(equalToConstant: 250).isActive = true
            
            let xCenterConstraint = NSLayoutConstraint(item: poster, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: poster, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else if indexPath.row == 3
        {
            //////////////////////////////////////////////////////////////////////
            // Overview Title
            
            let overviewTitle = UILabel(frame : CGRect(x: 0, y: 100, width: 300, height: 100))
            overviewTitle.backgroundColor = .clear
            overviewTitle.font = UIFont.boldSystemFont(ofSize: 18)
            cell.contentView.addSubview(overviewTitle)
            overviewTitle.translatesAutoresizingMaskIntoConstraints = false
            overviewTitle.text = "About the Movie"
           
            let xCenterConstraint = NSLayoutConstraint(item: overviewTitle, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: overviewTitle, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else if indexPath.row == 4
        {
            //////////////////////////////////////////////////////////////////////
            // Overview
            
            let overviewLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 345, height: 300))
            overviewLabel.font = UIFont.systemFont(ofSize: 14)
            overviewLabel.numberOfLines = 0
            cell.contentView.addSubview(overviewLabel)
            overviewLabel.text = self.movieResults?.overview!
            
            overviewLabel.lineBreakMode = .byWordWrapping
            overviewLabel.textAlignment = NSTextAlignment.center
            overviewLabel.sizeToFit()
            
            let xCenterConstraint = NSLayoutConstraint(item: overviewLabel, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: overviewLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else if indexPath.row == 5
        {
            //////////////////////////////////////////////////////////////////////
            // Reviews Title
            
            let reviewTitle = UILabel(frame : CGRect(x: 0, y: 100, width: 300, height: 100))
            reviewTitle.backgroundColor = .clear
            reviewTitle.font = UIFont.boldSystemFont(ofSize: 18)
            cell.contentView.addSubview(reviewTitle)
            reviewTitle.translatesAutoresizingMaskIntoConstraints = false
            reviewTitle.text = "Reviews"
            
            let xCenterConstraint = NSLayoutConstraint(item: reviewTitle, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            cell.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: reviewTitle, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            cell.addConstraint(yCenterConstraint)
        }
        else
        {
            //////////////////////////////////////////////////////////////////////
            // Reviews Given

            let revTit = reviewArray[indexPath.row-6].reviewtitle!
            let revCon = reviewArray[indexPath.row-6].reviewcontent!
            let revLike = String(reviewArray[indexPath.row-6].noOfLikes!)
            let revDislike = String(reviewArray[indexPath.row-6].noOfDislikes!)
            let usrNm = reviewArray[indexPath.row-6].userName!
            let tempUId = reviewArray[indexPath.row-6].userId!
            
            print("revLike: ", revLike)
            print("revDislike: ", revDislike)
            
            let revUsr = UILabel(frame : CGRect(x: 0, y: 10, width: 300, height: 5))
            revUsr.backgroundColor = UIColor.clear
            revUsr.font = UIFont.boldSystemFont(ofSize: 16)
            cell.contentView.addSubview(revUsr)
            revUsr.translatesAutoresizingMaskIntoConstraints = false
            revUsr.text = usrNm + " says: "//+ isLikeText + " says: "
            revUsr.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let reviewDetail = UILabel(frame : CGRect(x: 0, y: 10, width: 300, height: 10))
            reviewDetail.backgroundColor = UIColor.clear
            reviewDetail.font = UIFont.systemFont(ofSize: 14)
            cell.contentView.addSubview(reviewDetail)
            reviewDetail.translatesAutoresizingMaskIntoConstraints = false
            reviewDetail.text = revTit
            reviewDetail.heightAnchor.constraint(equalToConstant: 20).isActive = true
            reviewDetail.topAnchor.constraint(equalTo: revUsr.bottomAnchor).isActive = true

            let reviewDetail2 = UILabel(frame : CGRect(x:0, y: 50, width: 300, height: 20))
            reviewDetail2.backgroundColor = UIColor.clear
            reviewDetail2.font = UIFont.systemFont(ofSize: 14)
            cell.contentView.addSubview(reviewDetail2)
            reviewDetail2.translatesAutoresizingMaskIntoConstraints = false
            reviewDetail2.text = revCon
            reviewDetail2.heightAnchor.constraint(equalToConstant: 20).isActive = true
            reviewDetail2.topAnchor.constraint(equalTo: reviewDetail.bottomAnchor).isActive = true
            
            let editButton = UIButton(frame : CGRect(x:275, y: 10, width: 75, height: 20))
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(UIColor.white, for: .normal)
            editButton.layer.cornerRadius = 5
            editButton.layer.borderWidth = 1
            editButton.layer.backgroundColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35).cgColor
            editButton.layer.borderColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35).cgColor
            editButton.accessibilityIdentifier = tempUId
            editButton.addTarget(self, action: #selector(handleEditReview), for: .touchUpInside)
            //editButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            ///editButton.topAnchor.constraint(equalTo: reviewDetail2.bottomAnchor).isActive = true
            cell.contentView.addSubview(editButton)
            
            let deleteButton = UIButton(frame : CGRect(x:275, y: 32, width: 75, height: 20))
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.setTitleColor(UIColor.white, for: .normal)
            deleteButton.layer.cornerRadius = 5
            deleteButton.layer.borderWidth = 1
            deleteButton.layer.backgroundColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35).cgColor
            deleteButton.layer.borderColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35).cgColor
            deleteButton.accessibilityIdentifier = tempUId
            deleteButton.addTarget(self, action: #selector(handleDeleteReview), for: .touchUpInside)
            //editButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            ///editButton.topAnchor.constraint(equalTo: reviewDetail2.bottomAnchor).isActive = true
            cell.contentView.addSubview(deleteButton)
            
            let likeButton = UIButton(frame : CGRect(x:70, y: 75, width: 35, height: 35))
            likeButton.setImage(UIImage(named: "Facebook-Like"), for: .normal)
            likeButton.contentMode = .scaleToFill
            likeButton.tag = reviewArray[indexPath.row-6].noOfLikes!
            likeButton.addTarget(self, action: #selector(handleLikeReview), for: .touchUpInside)
            likeButton.clipsToBounds = true
            likeButton.accessibilityIdentifier = tempUId
            cell.contentView.addSubview(likeButton)

            let dislikeButton = UIButton(frame : CGRect(x:150, y: 85, width: 35, height: 35))
            dislikeButton.setImage(UIImage(named: "Facebook-Dislike"), for: .normal)
            dislikeButton.contentMode = .scaleToFill
            dislikeButton.clipsToBounds = true
            dislikeButton.tag = reviewArray[indexPath.row-6].noOfDislikes!
            dislikeButton.addTarget(self, action: #selector(handleDislikeReview), for: .touchUpInside)
            dislikeButton.accessibilityIdentifier = tempUId
            cell.contentView.addSubview(dislikeButton)

            let likeLabel = UILabel(frame : CGRect(x:70, y: 120, width: 35, height: 20))
            likeLabel.backgroundColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35)
            likeLabel.textAlignment = .center
            likeLabel.font = UIFont.systemFont(ofSize: 14)
            cell.contentView.addSubview(likeLabel)
            likeLabel.text = revLike

            let dislikeLabel = UILabel(frame : CGRect(x:150, y: 120, width: 35, height: 20))
            dislikeLabel.backgroundColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35)
            dislikeLabel.textAlignment = .center
            dislikeLabel.font = UIFont.systemFont(ofSize: 14)
            cell.contentView.addSubview(dislikeLabel)
            dislikeLabel.text = revDislike

        }
        //cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 2
        {
            return 180
        }
        else if indexPath.row == 4
        {
            return 170
        }
        else if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5
        {
            return 40
        }
        else
        {
            // Height for the rows of reviews
            return 150
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getImage() -> UIImage
    {
        let rating = self.movieResults?.vote_average
        var imageName = UIImage(named: "default-rating")
        
        if rating != nil
        {
            if Double(rating!) > Double(9.1)
            {
                imageName = UIImage(named: "image-5.0")!
            }
            else if Double(rating!) > Double(8.1) && Double(rating!) <= Double(9.0)
            {
                imageName = UIImage(named: "image-4.5")!
            }
            else if Double(rating!) > Double(7.1) && Double(rating!) <= Double(8.0)
            {
                imageName = UIImage(named: "image-4.0")!
            }
            else if Double(rating!) > Double(6.1) && Double(rating!) <= Double(7.0)
            {
                imageName = UIImage(named: "image-3.5")!
            }
            else if Double(rating!) > Double(5.1) && Double(rating!) <= Double(6.0)
            {
                imageName = UIImage(named: "image-3.0")!
            }
            else if Double(rating!) > Double(4.1) && Double(rating!) <= Double(5.0)
            {
                imageName = UIImage(named: "image-2.5")!
            }
            else if Double(rating!) > Double(3.1) && Double(rating!) <= Double(4.0)
            {
                imageName = UIImage(named: "image-2.0")!
            }
            else if Double(rating!) > Double(2.1) && Double(rating!) <= Double(3.0)
            {
                imageName = UIImage(named: "image-1.5")!
            }
            else if Double(rating!) > Double(1.1) && Double(rating!) <= Double(2.0)
            {
                imageName = UIImage(named: "image-1.0")!
            }
            else if Double(rating!) >= Double(0.0) && Double(rating!) <= Double(1.0)
            {
                imageName = UIImage(named: "image-0.5")!
            }
        }
        let myThumb = imageName?.resized(toWidth: 120.0)
        
        return myThumb!
    }
    
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ())
    {
        print("b")
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard data != nil else {
                print("no data")
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }; task.resume()
    }
    
    func downloadJSON(link: String, completed: @escaping () -> () )
    {
        let url = URL(string: link) //"https://api.themoviedb.org/3/movie/popular?api_key=2141436cc1d11d1aa9f276be95e352c4")
        URLSession.shared.dataTask(with: url!)
        {
            (data, response, err) in
            if err == nil
            {
                // check downloaded JSON data
                guard let jsondata = data else
                {
                    print("Error: ", err!)
                    completed()
                    return
                }
                
                do
                {
                    self.movieResults = try JSONDecoder().decode(MovieAttrInfo.self, from: jsondata)
                    DispatchQueue.main.async
                    {
                            completed()
                    }
                }
                catch let error
                {
                    print("Error: ", error)
                    print("JSON Downloading Error!")
                }
            }
            }.resume()
    }
}

extension UIImage
{
    func resized(withPercentage percentage: CGFloat) -> UIImage?
    {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer
        {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()

    }
    func resized(toWidth width: CGFloat) -> UIImage?
    {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer
        {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
