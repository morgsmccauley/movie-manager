//
//  MovieCollectionViewCell.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 17/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    var posterPath: String = "" {
        didSet {
            updatePoster();
        }
    }
    
    var moviePosterDelegate: MoviePosterDelegate?;
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    
    
    func updatePoster() {
        print("update poster");
        
        //start loading
        
        moviePosterDelegate?.fetchMoviePosterWith(posterPath: posterPath) { moviePoster in
            print(moviePoster);
            self.moviePoster.image = moviePoster;
        }
        
        //set no image
        
        //end loading
    }
}
