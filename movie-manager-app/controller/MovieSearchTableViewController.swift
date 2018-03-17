//
//  MovieSearchTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 1/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let DEFAULT_ROW_HEIGHT = CGFloat(211);

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieManagerDelegate{
    @IBOutlet weak var searchBar: UISearchBar!;

    let movieManager = MovieManager();

    var searchText: String = "" {
        didSet {
            if (!searchText.isEmpty) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.executeSearch(text: self!.searchText);
                }
            } else {
                clearSearchResults();
            }
        }
    }

    var searchResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;

        searchBar.delegate = self;
        movieManager.delegate = self;
    }
    
    func executeSearch(text: String) {
        let isLatestSearchText = self.searchText == text;
        if (isLatestSearchText) {
            self.movieManager.fetchMoviesFor(query: self.searchText);
        }
    }

    func movieFetchComplete(movies: [Movie]) {
        searchResults = movies;
    }
    
    func clearSearchResults() {
        searchResults = [];
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard();
    }
    
    func dismissKeyboard() {
        if (self.searchBar.isFirstResponder) {
            DispatchQueue.main.async {
                self.searchBar.endEditing(true);
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard();
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! MovieSearchTableViewCell;
        let movie = searchResults[(indexPath as NSIndexPath).row];

        row.backdrop.image = nil;
        
        row.movieTitle?.text = movie.title;
        row.releaseDate?.text = movie.releaseDate;
        getBackdrop(movie, row);

        return row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "MovieDetailSegue" else { return; }
        
        if let row = sender as? MovieSearchTableViewCell,
            let indexPath = self.tableView!.indexPath(for: row),
            let destination = segue.destination as? MovieDetailViewController,
            let _ = destination.view { //force view to load outlets
            
            let movie = searchResults[(indexPath as NSIndexPath).row];
            destination.backdrop.image = row.backdrop.image;
            destination.movie = movie;
            getRuntime(movie, destination);
            getMoviePoster(movie, destination);
            getCast(movie, destination);
            getReviews(movie, destination);
        }
    }
    
    func getBackdrop(_ movie: Movie, _ row: MovieSearchTableViewCell) {
        let backdropPath = movie.backdropPath;
        movieManager.fetchImage(path: backdropPath) { backdrop in
            DispatchQueue.main.async {
                if let backdrop = backdrop {
                    row.backdrop.image = backdrop;
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
