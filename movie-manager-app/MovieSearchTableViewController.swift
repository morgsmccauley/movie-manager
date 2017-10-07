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

//both these classes should inherit from a base class that does the integration with the model
class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!;

    let movieManager = MovieManager();

    var searchText: String = "" {
        didSet {
            movieManager.fetchMoviesFor(query: searchText)
        }
    }

    var searchResults: [Movie] = [] {
        didSet {
            if searchResults.count > 0 {
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

        self.tableView.rowHeight = 170;

        searchBar.delegate = self;
        movieManager.delegate = self;
    }

    func movieFetchComplete(movies: [Movie]) {
        searchResults = movies;
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search changed: " + searchText);
        self.searchText = searchText;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_VIEW_CELL_IDENTIFIER, for: indexPath) as! MovieSearchTableViewCell;

        let movieForRow = searchResults[(indexPath as NSIndexPath).row];

        cell.movieTitle?.text = movieForRow.title;
        cell.releaseDate?.text = movieForRow.releaseDate;

        let posterPath = movieForRow.posterPath;
        movieManager.fetchImage(path: posterPath) { returnedMoviePoster in
            DispatchQueue.main.async {

                if let poster = returnedMoviePoster {
                    cell.moviePoster.image = poster;
//                    cell.hasPoster = true;

//                    self.movieResults[indexPath.row].poster = poster;
                } else {
//                    cell.hasPoster = false;
                }
            }
        }

        return cell
    }
}
