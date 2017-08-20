//
//  movie.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit

protocol MoviePosterDelegate {
    
//    func fetchPosterFrom(path: String, completionHandler: @escaping ((UIImage?) -> ()));
}

class Movie {
 
    let title: String;
    let posterPath: String;
    var poster: UIImage? = nil;
    
    //let id: Int;
    //genre
    //overview
    //release date
    //image - use delegate?
    //rating
    
    init(title: String, posterPath: String) {
        self.title = title;
        self.posterPath = posterPath;
//        self.moviePosterDelegate = moviePosterDelegate;
    }
}
