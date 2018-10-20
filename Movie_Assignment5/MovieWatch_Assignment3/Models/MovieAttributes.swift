//
//  MovieAttributes.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 3/22/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Foundation

struct Genre: Decodable
{
    let id: Int?
    let name: String?
}

// https://api.themoviedb.org/3/movie/337167/images?api_key=2141436cc1d11d1aa9f276be95e352c4

struct MovieAttrInfo: Decodable
{
    let id: Int?
    let original_title: String?
    let poster_path: String? //CNContact
    let backdrop_path: String?
    var genres: [Genre]?
    let overview: String?
    let vote_average: Float?
    let vote_count: Int?
    
    private enum CodingKeys: String, CodingKey
    {
        case id, original_title = "original_title", poster_path, backdrop_path, overview, vote_average, vote_count, genres
    }
}

