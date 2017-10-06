//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
  
    @IBOutlet weak var movieImage: UIImageView! {
        didSet {
            let imageFrame = CGRect(x: 0.0, y: 0.0, width: movieImage.frame.width, height: movieImage.frame.height)
            movieImage.addGradientLayer(frame: imageFrame);
        }
    }
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    var movie: Movie? {
        didSet {
            setUpView();
        }
    }

    func setUpView() {
        
        let _ = self.view; //force the view to load its outlets. why is this necessary?
        
        self.title = movie?.title;
        movieTitle?.text = movie?.title;
        movieTitle?.sizeToFit();
        movieOverview.text = movie?.overview;
        movieOverview.sizeToFit()
    }
    
    override func viewDidLoad() {
        print("view did load");
        view.backgroundColor = UIColor.lightGray;
        movieOverview.backgroundColor = UIColor.lightGray;
    }

}

extension UIImageView {
    func addGradientLayer(frame: CGRect){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.lightGray.cgColor]
        gradient.locations = [0.85, 1]
        self.layer.addSublayer(gradient)
    }
}
