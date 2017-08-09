//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    var movie: Movie? {
        didSet {
            setUpView();
        }
    }

    func setUpView() {
        print("set up view");
        
        self.title = movie?.title;
    }

}
