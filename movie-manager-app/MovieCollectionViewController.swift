//
//  MovieCollectionViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 17/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MovieCell"

class MovieCollectionViewController: UICollectionViewController {
    
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
        print("search for movies");
        
        movieManager.fetchMovies(withTitle: searchText!) { movieResults in
            //dont force unwrap
            self.movieResults = movieResults!;
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        
        searchText = "Jurassic";
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieResults.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        
        print("cell for \(movieResults[indexPath.row].title)");
    
        //pass movie to cell - including delegate?
        cell.moviePoster.image = nil;
        cell.movieTitle.text? = movieResults[indexPath.row].title;
        cell.moviePosterDelegate = movieResults[indexPath.row].moviePosterDelegate;
        cell.posterPath = movieResults[indexPath.row].posterPath;
    
        return cell
    }
}
