//
//  MovieDetails.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 3/20/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Foundation

struct MovieInfo: Decodable
{
    var id: Int?
    var poster_path: String? //CNContact
    var title: String?
    
    init(id: Int, title: String, poster_path: String)
    {
        self.id = id
        self.title = title
        self.poster_path = poster_path
        //ref = Database.database().reference().child("favourites").childByAutoId()
    }
}

struct MovieResults: Decodable
{
    let page: Int?
    let total_results: Int?
    let total_pages: Int?
    var results: [MovieInfo]?
    
    private enum CodingKeys: String, CodingKey
    {
        case page, total_results, total_pages, results
    }
}

