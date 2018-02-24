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
    var fetchInProgress = false;
    var currentPageRequestNumber = 1;
//    var currentDiscoverySearchMethod: (MovieManager) -> (Int) -> () = MovieManager.fetchPopularMovies;
    
    let minHeaderHeight: CGFloat = 0;
    let maxHeaderHeight: CGFloat = 90;
    var previousScrollOffset:CGFloat = 0;
    var isInitialScroll = true; //to prevent header changing from initial hide status bar scroll
    
    func movieFetchComplete(movies: [Movie]) {
        fetchInProgress = false;
        self.movieResults.append(contentsOf: movies);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        movieManager.delegate = self;
        setUpCollectionViewLayout();
        movieManager.fetchPopularMovies(page: currentPageRequestNumber);
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
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        let isAtBottom = scrollView.contentOffset.y == absoluteBottom; //make it load earlier
        
        if (isAtBottom) {
            loadNextPage();
        }
        
        if (isScrollingUp || isScrollingDown) {
            setHeaderHeight(diff: scrollDiff, isScrollingDown: isScrollingDown, isScrollingUp: isScrollingUp);
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    func setHeaderHeight(diff: CGFloat, isScrollingDown: Bool, isScrollingUp: Bool) {
        var newHeight = self.headerHeightConstraint.constant
        
        if (isScrollingDown) {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(diff))
        } else if (isScrollingUp) {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(diff))
        }
        
        if newHeight != self.headerHeightConstraint.constant {
            self.headerHeightConstraint.constant = newHeight
        }
    }
    
    func loadNextPage() {
        guard (!fetchInProgress) else { return; }
        
        currentPageRequestNumber = currentPageRequestNumber + 1;
        movieManager.fetchPopularMovies(page: currentPageRequestNumber);
    }
}
