//
//  MovieSearchTableViewCell.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 6/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var runtime: UILabel!
    
    func setUpView() {
        moviePoster.image = nil;
    }
}
