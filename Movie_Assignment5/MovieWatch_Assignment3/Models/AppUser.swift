//
//  AppUser.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/10/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import Foundation
import Firebase

struct AppUser{
    var username: String?
    var uid: String?
    var email: String?
    var profileurl: String?
}

class AppReview
{
    var reviewId: String?
    var reviewcontent: String?
    var reviewtitle: String?
    //var isLike: Int?
    var userName: String?
    var noOfLikes: Int?
    var noOfDislikes: Int?
    var userId: String?
    
    let ref: DatabaseReference!
    
    
    init(reviewId: String, reviewcontent: String, reviewtitle: String, isLike: Int, userName: String, userId: String, noOfLikes: Int, noOfDislikes: Int) {
        //self.text = text
        //ref = Database.database().reference().child("reviews")
        self.reviewId = reviewId
        self.reviewcontent = reviewcontent
        self.reviewtitle = reviewtitle
        //self.isLike = isLike
        self.userName = userName
        self.userId = userId
        self.noOfLikes = noOfLikes
        self.noOfDislikes = noOfDislikes
        ref = Database.database().reference().child("reviews").childByAutoId()
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        if let value = snapshot.value as? [String : Any]
        {
            print("value in snapshot: ", value)
            reviewId = value["reviewId"] as? String
            reviewcontent = value["reviewcontent"] as? String
            reviewtitle = value["reviewtitle"] as? String
            //isLike = value["isLike"] as! Int
            userName = value["userName"] as! String!
            userId = value["userId"] as! String!
            noOfLikes = value["noOfLikes"] as! Int!
            noOfDislikes = value["noOfDislikes"] as! Int!
        }
    }
    
    func save()
    {
        ref.setValue(toDictionary())
    }
    
    func toDictionary() -> [String: Any]
    {
        return
        [
            "reviewId" : reviewId,
            "reviewcontent" : reviewcontent,
            "reviewtitle" : reviewtitle,
            //"isLike" : isLike,
            "userName" : userName,
            "noOfLikes": noOfLikes,
            "noOfDislikes": noOfDislikes,
            "userId": userId
        ]
    }
}

class UserFav
{
    var movieId: String?
    var movieTitle: String?
    var path: String?
    
    let ref: DatabaseReference!
    
    
    init(movieId: String, movieTitle: String, path: String)
    {
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.path = path
        ref = Database.database().reference().child("favourites").childByAutoId()
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        if let value = snapshot.value as? [String : Any]
        {
            //print("value in snapshot: ", value)
            movieId = value["movieId"] as? String
            movieTitle = value["movieTitle"] as? String
            path = value["path"] as? String
        }
    }
    
    func save()
    {
        ref.setValue(toDictionary())
    }
    
    func toDictionary() -> [String: Any]
    {
        return
            [
                "movieId" : movieId,
                "movieTitle" : movieTitle,
                "path" : path
        ]
    }
}


