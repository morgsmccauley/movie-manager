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
//        self.collectionView!.reloadData();
        
        movieManager.fetchMovies(withTitle: searchText!) { movieResults in
            
            self.movieResults = movieResults!;
//            self.tableView.reloadData();
            
            
            self.collectionView!.reloadData();
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        searchText = "Jurassic";
//    }

    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        searchText = "Jurassic";
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return movieResults.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell for row at");
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        
        cell.backgroundColor = UIColor.gray
        
//        cell.movieTitle = UILabel();
        
        print(cell);
        
        
    
        
//        print(cell.movieTitle.text);
        cell.movieTitle.text? = movieResults[indexPath.row].title;
        


    
        // Configure the cell
    
        return cell
    }


}
