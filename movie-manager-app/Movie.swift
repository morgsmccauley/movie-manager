//
//  movie.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit

class Movie {
 
    let id: Int;
    let title: String;
    let posterPath: String;
    let backdropPath: String;
    let releaseDate: String;
    let overview: String;
    let popularity: Int;
    
    var poster: UIImage? = nil;
    
    init(id: Int, title: String, posterPath: String, backdropPath: String, releaseDate: String, overview: String, popularity: Int) {
        self.id = id;
        self.title = title;
        self.posterPath = posterPath;
        self.backdropPath = backdropPath;
        self.releaseDate = releaseDate;
        self.overview = overview;
        self.popularity = popularity;
    }
}
