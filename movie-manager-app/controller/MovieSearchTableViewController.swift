//
//  MovieSearchTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 1/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let DEFAULT_ROW_HEIGHT = CGFloat(211);

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieViewControllerProtocol, MovieManagerDelegate{
    @IBOutlet weak var searchBar: UISearchBar!;

    let movieManager = MovieManager();

    var searchText: String = "" {
        didSet {
            if (!searchText.isEmpty) {
                executeSearch(text: searchText);
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let isLatestSearchText = self?.searchText == text;
            if (isLatestSearchText) {
                self?.movieManager.fetchMoviesFor(query: self!.searchText);
            }
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        searchBar.showsCancelButton = false;
        clearSearchResults();
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
        let row = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! MovieTableViewCell;
        let movie = searchResults[(indexPath as NSIndexPath).row];

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
            
            let movie = searchResults[(indexPath as NSIndexPath).row];
            destination.backdrop.image = row.backdrop.image;
            destination.movie = movie;
            self.getRuntime(for: movie, passTo: destination);
            self.getPoster(for: movie, passTo: destination);
            self.getCast(for: movie, passTo: destination);
            self.getReviews(for: movie, passTo: destination);
        }
    }
}
