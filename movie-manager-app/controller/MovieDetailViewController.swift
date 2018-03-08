//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
  
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var releaseYear: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var reviewTableView: UITableView!
    
    
    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    var movie: Movie! {
        didSet {
            self.name.text = movie.title;
            self.overview.text = movie.overview;
            self.releaseYear.text = movie.releaseDate;
            self.runtime.text = movie.runtime;
            
            print(movie);
        }
    }
}
