//
//  FavouriteMoviesTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 18/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

private let DEFAULT_ROW_HEIGHT = CGFloat(211);

class FavouriteMoviesTableViewController: UITableViewController {
    
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
        getBackdrop(movie, row);
        
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
            getBackdrop(movie, destination);
            getMoviePoster(movie, destination);
            getRuntime(movie, destination);
            getMoviePoster(movie, destination);
            getCast(movie, destination);
            getReviews(movie, destination);
        }
    }
    
    func getBackdrop(_ movie: Movie, _ row: MovieTableViewCell) {
        let backdropPath = movie.backdropPath;
        movieManager.fetchImage(path: backdropPath) { backdrop in
            DispatchQueue.main.async {
                if let backdrop = backdrop {
                    row.backdrop.image = backdrop;
                }
            }
        }
    }
    
    func getBackdrop(_ movie: Movie, _ destination: MovieDetailViewController) {
        let backdropPath = movie.backdropPath;
        movieManager.fetchImage(path: backdropPath) { backdrop in
            DispatchQueue.main.async {
                if let backdrop = backdrop {
                    destination.backdrop.image = backdrop;
                }
            }
        }
    }
    
    func getReviews(_ movie: Movie, _ destination: MovieDetailViewController) {
        movieManager.fetchReviews(movieId: movie.id) { reviews in
            destination.reviews = reviews!;
        }
    }
    
    func getCast(_ movie: Movie, _ destination: MovieDetailViewController) {
        movieManager.fetchCast(movieId: movie.id) { actors in
            destination.cast = actors!;
        }
    }
    
    func getMoviePoster(_ movie: Movie, _ destination: MovieDetailViewController) {
        movieManager.fetchImage(path: movie.posterPath) { poster in
            DispatchQueue.main.async {
                destination.poster.image = poster;
            }
        }
    }
    
    func getRuntime(_ movie: Movie, _ destination: MovieDetailViewController) {
        movieManager.fetchRuntime(movie: movie) { runtime in
            DispatchQueue.main.async {
                destination.runtime.text = runtime!;
            }
        }
    }
}
