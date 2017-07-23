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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    var posterPath: String = "" {
        didSet {
            updatePoster();
        }
    }
    
    var moviePosterDelegate: MoviePosterDelegate?;
    var cache = NSCache<AnyObject, AnyObject>();
    
    func updatePoster() {
        
        guard posterPath != "" else {
            setNoImage();
            return;
        }
        
        activityIndicator.startAnimating();
        
        if let cachedMoviePoster = cache.object(forKey: posterPath as AnyObject) as? UIImage {
            
            print("displaying cached image for \(self.movieTitle.text)");
            self.moviePoster.image = cachedMoviePoster;
            activityIndicator.stopAnimating();
        } else {
            moviePosterDelegate?.fetchMoviePosterWith(posterPath: posterPath) { [weak self] returnedMoviePoster in
                
                print("fethcing movie poster for \(self?.movieTitle.text)");
                
                if let moviePoster = returnedMoviePoster {
                    
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating();
                        self?.cache.setObject(moviePoster, forKey: self?.posterPath as AnyObject);
                        self?.moviePoster.image = moviePoster;
                    }
                } else {
                    print("no image");
                    self?.setNoImage();
                }
            }
            //set no image
        }
    }
    
    func setNoImage() {
        self.moviePoster.backgroundColor = UIColor.gray;
        activityIndicator.isHidden = true;
        noImageLabel.isHidden = false;
    }
}
