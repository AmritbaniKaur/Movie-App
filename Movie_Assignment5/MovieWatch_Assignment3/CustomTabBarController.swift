//
//  CustomTabBarController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/21/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit

class CustomTabBarController : UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup our custom view controllers
        let popularController = UINavigationController(rootViewController: MovieTableViewController())
        let nowPlayingController = UINavigationController(rootViewController: NowPlayingMoviesTableViewController())
        let upcomingController = UINavigationController(rootViewController: UpcomingMoviesTableViewController())
        let topRatedController = UINavigationController(rootViewController: TopRatedMoviesTableViewController())
        let favoriteController = UINavigationController(rootViewController: UserFavoriteTableViewController())
        
        popularController.tabBarItem.title = "Popular"
        popularController.tabBarItem.image = UIImage(named: "Popular1")
        
        nowPlayingController.tabBarItem.title = "Now Playing"
        nowPlayingController.tabBarItem.image = UIImage(named: "Now-Playing")
        
        upcomingController.tabBarItem.title = "Upcoming"
        upcomingController.tabBarItem.image = UIImage(named: "upcoming")
        
        topRatedController.tabBarItem.title = "Top Rated"
        topRatedController.tabBarItem.image = UIImage(named: "TopRated2")
        
        favoriteController.tabBarItem.title = "Favorites"
        favoriteController.tabBarItem.image = UIImage(named: "Favourited")
        
        viewControllers = [favoriteController, topRatedController, popularController, nowPlayingController, upcomingController]
        //tabBarController?.selectedIndex = tabBarItem
        self.selectedIndex = 2
    }
}
