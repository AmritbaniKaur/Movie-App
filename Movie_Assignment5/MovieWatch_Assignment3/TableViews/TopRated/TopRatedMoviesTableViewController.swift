//
//  TopRatedMoviesTableViewController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/21/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

class TopRatedMoviesTableViewController: UITableViewController
{
    
    let defaults = UserDefaults.standard
    weak var activityIndicatorView: UIActivityIndicatorView!
    var ref: DatabaseReference!
    var favRef = Database.database().reference().child("favourites")
    var revRef = Database.database().reference().child("reviews")

    var reviewArray = [AppReview]()
    
    var appUser: AppUser?
    {
        didSet
        {
            //print("Value Set")
            //guard let username = appUser?.username else { return }
            //guard let profileurl = appUser?.profileurl else { return }
            
            setupNavBarItems()
            //navigationItem.title = username
        }
    }
    
    var results: MovieResults? // Data we will use
    //var results = [MovieResults]() // Data we will use
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("TopRatedController")

        ref = Database.database().reference()
        downloadJSON
        {
                
        }
        
        self.tableView.reloadData()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // add activityIndicatorView to view controller, so viewWillAppear will be called
        self.activityIndicatorView = activityIndicatorView
        
        navigationItem.title = "Top Rated"
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let logoutBtn = UIButton()
        logoutBtn.setImage(UIImage(named: "Logout.png"), for: .normal)
        //logoutBtn.frame = CGRect(x:350, y:0, width:20, height: 20)
        logoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        logoutBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        logoutBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let item1 = UIBarButtonItem()
        item1.customView = logoutBtn
        navigationItem.rightBarButtonItem = item1
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        fetchUserInfo()
        
        tableView.register(TopRatedMoviesCell.self, forCellReuseIdentifier: "cellidtoprated")
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        tableView.reloadData()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func setupNavBarItems()
    {
        guard let username = appUser?.username else { return }
        print(username)
        
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
    
    func fetchUserInfo()
    {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userId).observeSingleEvent(of: .value){ (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let username = data["username"] as? String else { return }
            guard let email = data["email"] as? String else { return }
            guard let profileurl = data["profileurl"] as? String else { return }
            self.appUser = AppUser(username: username, uid: userId, email: email, profileurl: profileurl)
        }
    }
    
    func downloadJSON(completed: @escaping () -> () )
    {
        let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=2141436cc1d11d1aa9f276be95e352c4")
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
                    self.results = try JSONDecoder().decode(MovieResults.self, from: jsondata)
                    DispatchQueue.main.async
                        {
                            completed()
                    }
                }
                catch //let error
                {
                    //print("Error: ", error)
                    print("JSON Downloading Error!")
                }
            }
            }.resume()
    }
    
    
    
    // called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        //self.tableView.reloadData()
        
        if self.results?.results!.count == 0 || results?.results!.count == nil
        {
            activityIndicatorView.startAnimating()
            
            // add delay! after deadline, run the execute closure!
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.activityIndicatorView.stopAnimating()
                
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                self.tableView.reloadData()
            })
        }
        
        setupNavBarItems()
    }
    
    // Table View Cell for Row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = TopRatedMoviesCell(style: .default, reuseIdentifier: "cellidtoprated")
        //print("Hits here!")
        
        self.downloadJSON
            {
           
                cell.link = self
                
                let movie1 = self.results?.results![indexPath.row]
                let name = movie1?.title
                cell.movieName.text = name
                let path = self.results?.results![indexPath.row].poster_path!
                let movieId = String(movie1!.id!)
                
                guard let tempUserId = Auth.auth().currentUser?.uid else { return }
                let tempMovieId = self.results!.results![indexPath.row].id!

                cell.imageFav.setImage(UIImage(named: "favourite2"), for: .normal)
                cell.imageFav.setImage(UIImage(named: "favourite"), for: .selected)
                
                // Maintaining the Button State
                //let ref1 = Database.database().reference()
                self.ref.child("favourites").child(tempUserId).observe(.value, with: {(snapshot) in
                    
                    if snapshot.hasChild(String(movie1!.id!))
                    {
                        // Red
                        cell.imageFav.setImage(UIImage(named: "favourite"), for: .normal)
                        cell.imageFav.isSelected = true
                    }
                    else
                    {
                        // Black
                        cell.imageFav.setImage(UIImage(named: "favourite2"), for: .normal)
                        cell.imageFav.isSelected = false
                    }
                })
                
                cell.imageFav.addTarget(self, action: #selector(self.handleFavClick), for: .touchUpInside)
                //cell.imageFav.accessibilityIdentifier = tempUserId
                //cell.imageFav.tag = tempMovieId
                cell.imageFav.tag = indexPath.row
                
                cell.imageView?.image = UIImage(named: "cell-background");
                let downloadedImage = "https://image.tmdb.org/t/p/w154/" + path!
                self.getImageFromWeb(downloadedImage) { (image) in
                    if let image = image
                    {
                        cell.imageName.image = image
                    } // if you use an Else statement, it will be in background
                }
                
                // For printing the Number of Reviews
                print("Local Movie Id in CellForRowAt: ", movieId)
                self.revRef.child(movieId).observe(.value, with: {(snapshot) in
                    self.reviewArray.removeAll()
                    
                    for child in snapshot.children
                    {
                        let childSnapshot = child as! DataSnapshot
                        let review = AppReview(snapshot: childSnapshot)
                        print("review from new observe: ", review)
                        self.reviewArray.insert(review, at: 0)
                    }
                    
                    let textVal = String(self.reviewArray.count) + " Reviews"
                    //print("MovieId: ", movieId)
                    //print("Num of Reviews: ", movieId, textVal)
                    cell.reviewNum.text = textVal
                    //cell.movieName.backgroundColor = UIColor.red
                    //cell.reviewNum.topAnchor.constraint(equalTo: cell.movieName.bottomAnchor).isActive = true

                    //self.tableView.reloadData()
                })
        }
        return cell
    }
    
    @objc func handleFavClick(sender: UIButton)
    {
        guard let tempUserId = Auth.auth().currentUser?.uid else { return }

        let indexRow = sender.tag
        print("tempUserId: ", tempUserId)

        if(sender.isSelected == true)
        {
            print("Button is Deselected")
            sender.isSelected = false
            
            // Reflect in the database
            let tempMovieId = String(self.results!.results![indexRow].id!)
            print("Delete a Review!")
            print("Movie Id: ", tempMovieId)
            
            favRef.child(tempUserId).child(tempMovieId).removeValue()
            //self.reviewArray.removeAll()
            self.tableView.reloadData()
        }
        else
        {
            print("Button is Selected")
            sender.isSelected = true
            
            // Reflect in the database
            let path = self.results!.results![indexRow].poster_path!
            let movieId = String(self.results!.results![indexRow].id!)
            let movieTitle = self.results!.results![indexRow].title!
            let imagePath = "https://image.tmdb.org/t/p/w154/" + path
            
            print("handleFavClick")
            print("path: ", path)
            print("movieId: ", movieId)
            print("movieTitle: ", movieTitle)
            print("imagePath: ", imagePath)
            
            let values = ["movieId": movieId,
                          "movieTitle": movieTitle,
                          "path": path
            ]
            
            let favReference = favRef.child(tempUserId).child(movieId)//.child(tempReviewUserId)
            favReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
        }
        
    }
    
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ())
    {
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let movie = results?.results![indexPath.row] //as? String //results.results![indexPath.row]
        {
            self.showDetailOfMovie(movie: movie)
        }
    }
    
    func showDetailOfMovie(movie: MovieInfo)
    {
        let detailController = DetailViewController()
        detailController.movie = movie
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        if let number = self.results?.results?.count
        {
            return number
            //return results[section].results!.count //results[section].results!.count
        }
        return 0
    }
    
    // Height for each row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let index = indexPath.row
            //self.tableView.beginUpdates()
            //var dataToDelete = results?.results!
            self.results?.results!.remove(at: index) //.remove(at: indexPath.row) // <------ exception thrown
            //results!.results!.remove(at: inde)
            //print("Data after delete: ", results!.results!)
            //self.tableView.endUpdates()
            
            
            //tableView.beginUpdates()
            //self.tableView.reloadInputViews()
            //self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
            //viewWillAppear(true)
            //self.tableView(tableView: self.tableView, cellForRowAt: indexPath)
            
            //tableView.deleteRows(at: [indexPath], with: .fade) // <------ exception thrown
            //self.tableView.endUpdates()
        }
    }
    
    
    
}
