//
//  MovieCollectionViewCell.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 17/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    
    var posterPath: String = "" {
        didSet {
            updatePoster();
        }
    }
    
    var moviePosterDelegate: MoviePosterDelegate?;
    var cache = NSCache<AnyObject, AnyObject>();
    
    func updatePoster() {
        //start loading
        
        if let cachedMoviePoster = cache.object(forKey: posterPath as AnyObject) as? UIImage {
            print("displaying cached image");
            self.moviePoster.image = cachedMoviePoster;
        } else {
            moviePosterDelegate?.fetchMoviePosterWith(posterPath: posterPath) { [weak self] returnedMoviePoster in
                if let moviePoster = returnedMoviePoster {
                    self?.cache.setObject(moviePoster, forKey: self?.posterPath as AnyObject)
                    
                    DispatchQueue.main.async {
                        self?.moviePoster.image = moviePoster;
                    }
                }
            }
            //set no image
        }
        
        //end loading
    }
}
