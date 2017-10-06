//
//  MovieSearchTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 1/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let SEARCH_VIEW_CELL_IDENTIFIER = "SearchResultCell";

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
            print("search results: ");
            print(searchResults);
            DispatchQueue.main.async {
                self.tableView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        print("entered cell");

        let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_VIEW_CELL_IDENTIFIER, for: indexPath);



        cell.textLabel?.text = searchResults[(indexPath as NSIndexPath).row].title;

        return cell
    }
}
