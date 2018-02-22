//
//  MovieCollecitionViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 22/02/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDiscoveryViewController: UIViewController, MovieManagerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!;
    
    let movieManager = MovieManager();
    
    var movieResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    };
    
    func movieFetchComplete(movies: [Movie]) {
        self.movieResults = movies;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        movieManager.delegate = self;
        setUpCollectionViewLayout();
        movieManager.fetchPopularMovies();
    }
    
    func setUpCollectionViewLayout() {
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

extension MovieDiscoveryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieResults.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell;
        getMoviePoster(movieIndex: indexPath.row, cell: cell);

        return cell;
    }
    
    func getMoviePoster(movieIndex: Int, cell: MovieCollectionViewCell) {
        if let poster = movieResults[movieIndex].poster {
            cell.moviePoster.image = poster;
            return;
        }

        let posterPath = movieResults[movieIndex].posterPath;
        movieManager.fetchImage(path: posterPath) { poster in
            DispatchQueue.main.async {
                cell.moviePoster.image = poster;
                self.movieResults[movieIndex].poster = poster;
            }
        }
    }
}

extension MovieDiscoveryViewController: UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "MovieDetailSegue" else { return; }
        
        if let cell = sender as? MovieCollectionViewCell,
            let indexPath = self.collectionView!.indexPath(for: cell),
            let destination = segue.destination as? MovieDetailViewController {
            
            destination.movie = movieResults[(indexPath as NSIndexPath).row];
            
            let backdropPath = movieResults[(indexPath as NSIndexPath).row].backdropPath;
            movieManager.fetchImage(path: backdropPath) { returnedBackdrop in
                DispatchQueue.main.async {
                    destination.movieImage?.image = returnedBackdrop;
                }
            }
            
        }
    }
}
