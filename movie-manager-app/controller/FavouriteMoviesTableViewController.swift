//
//  FavouriteMoviesTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 18/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

private let DEFAULT_ROW_HEIGHT = CGFloat(211);

class FavouriteMoviesTableViewController: UITableViewController, MovieViewControllerProtocol {
    
    let movieManager = MovieManager();
    let favouriteMovieManager = FavourtieMovieManager();
    
    var favouriteMovies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        favouriteMovies = favouriteMovieManager.fetchSaved();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteMovies.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "FavouriteMovieCell", for: indexPath) as! MovieTableViewCell;
        let movie = favouriteMovies[(indexPath as NSIndexPath).row];
        
        row.backdrop.image = nil;
        
        row.movieTitle?.text = movie.title;
        row.releaseDate?.text = movie.releaseDate;
        self.getBackdrop(for: movie, passTo: row);
        
        return row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "MovieDetailSegue" else { return; }
        
        if let row = sender as? MovieTableViewCell,
            let indexPath = self.tableView!.indexPath(for: row),
            let destination = segue.destination as? MovieDetailViewController,
            let _ = destination.view { //force view to load outlets
            
            let movie = favouriteMovies[(indexPath as NSIndexPath).row];
            destination.movie = movie;
            self.getBackdrop(for: movie, passTo: destination);
            self.getPoster(for: movie, passTo: destination);
            self.getRuntime(for: movie, passTo: destination);
            self.getCast(for: movie, passTo: destination);
            self.getReviews(for: movie, passTo: destination);
        }
    }
}
