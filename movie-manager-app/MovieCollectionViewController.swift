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
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var searchController : UISearchController!
    
    var movieResults: [Movie] = [];
    let movieManager = MovieManager();
    
    var searchText: String? {
        
        didSet {
            searchForMovies();
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        setUpLayout();
        
        searchText = "star wars";
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movieResults.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell;
    
        cell.setUpView();
        cell.movieTitle.text? = movieResults[indexPath.row].title;

//        fetchPosterFor(&cell, at: indexPath.row);
        
        let posterPath = movieResults[indexPath.row].posterPath;
        movieManager.fetchPosterFrom(path: posterPath) { returnedMoviePoster in
         
            DispatchQueue.main.async {
                
                if let poster = returnedMoviePoster {
                    cell.moviePoster.image = poster;
                    cell.hasPoster = true;
                    
                    self.movieResults[indexPath.row].poster = poster;
                } else {
                    cell.hasPoster = false;
                }
            }
        }
        
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView();
    }
}

extension MovieCollectionViewController {
    
    func searchForMovies() {
        
        movieManager.fetchMovies(withTitle: searchText!) { movieResults in
            //dont force unwrap
            self.movieResults = movieResults!;
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    }
    
    func fetchPosterFor(_ cell: inout MovieCollectionViewCell, at movieIndex: Int) {
        
//        let posterPath = movieResults[movieIndex].posterPath
//        movieManager.fetchPosterFrom(path: posterPath) { returnedMoviePoster in
//            
//            DispatchQueue.main.async {
//            
//                if let poster = returnedMoviePoster {
//                    cell.moviePoster.image = poster;
//                    cell.hasPoster = true;
//            
//                    self.movieResults[movieIndex].poster = poster;
//                } else {
//                    cell.hasPoster = false;
//                }
//            }
//        }
    }
    
    func fetchPosterFor(movieIndex: Int) {
        
//        var cache = NSCache<AnyObject, AnyObject>();
//        if let cachedMoviePoster = cache.object(forKey: posterPath as AnyObject) as? UIImage {
//        self?.cache.setObject(moviePoster, forKey: self?.posterPath as AnyObject);
        
        let targetMovie: Movie = movieResults[movieIndex];
        let posterPath = targetMovie.posterPath;
        
        movieManager.fetchPosterFrom(path: posterPath) { [weak self] returnedMoviePoster in
            
            if let moviePoster = returnedMoviePoster {
                targetMovie.poster = moviePoster;
            }
            //deal with cache and no image found
            
            //does this need to be on main thread?
            self?.movieResults[movieIndex] = targetMovie;
        }
    }
    
    func setUpLayout() {
        let space: CGFloat = 0.0;
        
        let xDimension = (self.view.frame.size.width) / 3;
        let yDimension = xDimension * 1.5;
        
        flowLayout.minimumLineSpacing = space;
        flowLayout.minimumInteritemSpacing = space;
        flowLayout.itemSize = CGSize.init(width: xDimension, height: yDimension);
        
        let offset = CGPoint.init(x: 0, y: 44);
        self.collectionView?.contentOffset = offset;
    }
}

extension MovieCollectionViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "MovieViewSegue" else { return; }
        
        if let cell = sender as? MovieCollectionViewCell,
            let indexPath = self.collectionView!.indexPath(for: cell),
            let destination = segue.destination as? MovieViewController {
            
            destination.movie = movieResults[(indexPath as NSIndexPath).row];
        }
    }
}

extension MovieCollectionViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if(!(searchBar.text?.isEmpty)!){
            searchText = searchBar.text!
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            print("search changed");
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
}
