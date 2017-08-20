//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
  
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePlot: UITextField!
    
    var movie: Movie? {
        didSet {
            setUpView();
        }
    }

    func setUpView() {
        print("set up view");
        
        self.title = movie?.title;
        
        if let poster = movie?.poster {
            
            print(poster);
//            self.movieImage.image = poster;
//            self.movieTitle.text = movie?.title;
        }
        
//        movieTitle.text = movie?.title;
    }

}
