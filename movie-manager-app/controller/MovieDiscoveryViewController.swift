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
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!;
    
    let movieManager = MovieManager();
    var movieResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    };
    
    let minHeaderHeight: CGFloat = 0;
    let maxHeaderHeight: CGFloat = 90;
    var previousScrollOffset:CGFloat = 0;
    var isInitialScroll = true; //to prevent header changing from initial hide status bar scroll
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (isInitialScroll) {
            isInitialScroll = false;
            return;
        }
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = self.headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
        }
        
        if newHeight != self.headerHeightConstraint.constant {
            self.headerHeightConstraint.constant = newHeight
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
}
