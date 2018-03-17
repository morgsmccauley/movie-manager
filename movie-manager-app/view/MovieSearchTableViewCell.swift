//
//  MovieSearchTableViewCell.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 6/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    func setUpView() {
        backdrop.image = nil;
    }
}
