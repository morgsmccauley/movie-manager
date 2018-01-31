//
//  MovieSearchTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 1/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let SEARCH_VIEW_CELL_IDENTIFIER = "SearchResultCell";
private let MAX_SEARCH_RESULTS = 5;
private let DEFAULT_ROW_HEIGHT = CGFloat(170);

//both these classes should inherit from a base class that does the integration with the model - will this work?
class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieManagerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!;

    let movieManager = MovieManager();

    var searchText: String = "" {
        didSet {
            if (!searchText.isEmpty) {
                executeDelayedSearch(text: searchText);
            } else {
                clearSearchResults();
            }
        }
    }

    var searchResults: [Movie] = [] {
        didSet {
            if (searchResults.count > MAX_SEARCH_RESULTS) {
                let resultsGreaterThanMaxRange = searchResults.startIndex.advanced(by: MAX_SEARCH_RESULTS)..<searchResults.endIndex;
                searchResults.removeSubrange(resultsGreaterThanMaxRange);
            }

            DispatchQueue.main.async {
                self.tableView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = DEFAULT_ROW_HEIGHT; //why cant i set this statically in the view ?

        searchBar.delegate = self;
        movieManager.delegate = self;
    }
    
    func executeDelayedSearch(text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let isLatestSearchText = self.searchText == text;
            if (isLatestSearchText) {
                print("executing search: " + self.searchText)
                self.movieManager.fetchMoviesFor(query: self.searchText);
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: SEARCH_VIEW_CELL_IDENTIFIER, for: indexPath) as! MovieSearchTableViewCell;

        let movieForRow = searchResults[(indexPath as NSIndexPath).row];

        row.movieTitle?.text = movieForRow.title;
        row.releaseDate?.text = movieForRow.releaseDate;
        row.genres?.text = movieForRow.genres;
        row.runtime?.text = movieForRow.runtime;
//        row.popularity?.text = movieForRow.popularity;

        row.setUpView();

        let posterPath = movieForRow.posterPath;
        movieManager.fetchImage(path: posterPath) { returnedMoviePoster in
            DispatchQueue.main.async {

                if let poster = returnedMoviePoster {
                    row.moviePoster.image = poster;
//                    cell.hasPoster = true;

//                    self.movieResults[indexPath.row].poster = poster;
                } else {
//                    cell.hasPoster = false;
                }
            }
        }

        return row
    }
}
