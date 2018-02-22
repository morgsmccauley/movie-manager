//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
  
    @IBOutlet weak var movieImage: UIImageView! //need to set height for this
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    var movie: Movie? {
        didSet {
            movieTitle?.text = movie?.title;
            movieOverview?.text = movie?.overview;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let _ = self.view; //force the view to load its outlets.
    }

}
