//
//  movie.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit

struct Movie {
 
    let id: Int;
    let title: String;
    let posterPath: String;
    let backdropPath: String;
    let releaseDate: String;
    let overview: String;
    let popularity: String;

    var genres: String = "";
    var budget: String = "";
    var company: String = "";
    var runtime: String = "";

    init(id: Int, title: String, posterPath: String, backdropPath: String, releaseDate: String, overview: String, popularity: String) {
        self.id = id;
        self.title = title;
        self.posterPath = posterPath;
        self.backdropPath = backdropPath;
        self.releaseDate = releaseDate;
        self.overview = overview;
        self.popularity = popularity;
    }
}
