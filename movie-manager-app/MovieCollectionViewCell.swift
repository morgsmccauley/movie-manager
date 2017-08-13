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
    
    var hasPoster: Bool = false {
        didSet {
            
            activityIndicator.stopAnimating();
            activityIndicator.isHidden = true;
            
            if !hasPoster {
                setNoImage();
            }
        }
    }
    
    func setUpView() {
        moviePoster.image = nil;
        activityIndicator.startAnimating();
        activityIndicator.isHidden = false;
        noImageLabel.isHidden = true;
    }
    
    func setNoImage() {
        self.moviePoster.backgroundColor = UIColor.gray;
        noImageLabel.isHidden = false;
    }
}
