//
//  MovieTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 5/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit
import Foundation

class MovieTableViewController: UITableViewController {

    
    private var movieResults: [Movie] = [];
    
    let movieManager = MovieManager();
    
    var searchText: String? {
        
        didSet {
            //remove all movie results
            //reload table view
            searchForMovies();
            //set the title as the search string
        }
    }
    
    //make sure tasks are dispatched on correct queues
    func searchForMovies() {
        
        movieManager.fetchMovies(withTitle: searchText!) { movieResults in
            
            self.movieResults = movieResults!;
            self.tableView.reloadData();
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchText = "Jurassic";
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movieResults.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)

        cell.textLabel?.text = movieResults[indexPath.row].title;

        return cell
    }
}
