//
//  MovieCollectionViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 17/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let COLLECTION_VIEW_CELL_IDENTIFIER = "MovieCell";
private let COLLECTION_VIEW_HEADER_IDENTIFIER = "CollectionViewHeader";

class MovieCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!;
    
    let movieManager = MovieManager();
    
    var movieResults: [Movie] = [] {
        
        didSet {
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    };

    var searchText: String? {
        
        didSet {
            searchForMovies();
        }
    };
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        movieManager.delegate = self;
        setUpLayout();
        movieManager.fetchPopularMovies();
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movieResults.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COLLECTION_VIEW_CELL_IDENTIFIER, for: indexPath) as! MovieCollectionViewCell;
    
        cell.setUpView();
        cell.movieTitle.text? = movieResults[indexPath.row].title;
        
        if let poster = movieResults[indexPath.row].poster {
            
            cell.moviePoster.image = poster;
            cell.hasPoster = true;
        } else {
            
            let posterPath = movieResults[indexPath.row].posterPath;
            movieManager.fetchImage(path: posterPath) { returnedMoviePoster in
                
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
        }
        
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: COLLECTION_VIEW_HEADER_IDENTIFIER, for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView();
    }
}

/*
 *  Interact with model
 */
extension MovieCollectionViewController: MovieManagerDelegate {
    
    func movieFetchComplete(movies: [Movie]) {
        self.movieResults = movies;
    }

    func searchForMovies() {
        
        movieManager.fetchMoviesFor(query: searchText!);
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


/*
 *  Segue
 */
extension MovieCollectionViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "MovieViewSegue" else { return; }
        
        if let cell = sender as? MovieCollectionViewCell,
            let indexPath = self.collectionView!.indexPath(for: cell),
            let destination = segue.destination as? MovieViewController {
            
            destination.movie = movieResults[(indexPath as NSIndexPath).row];
            
            let backdropPath = movieResults[(indexPath as NSIndexPath).row].backdropPath;
            print(backdropPath);
            movieManager.fetchImage(path: backdropPath) { returnedBackdrop in
                
                DispatchQueue.main.async {
                    destination.movieImage?.image = returnedBackdrop;
                }
            }
            
        }
    }
}
