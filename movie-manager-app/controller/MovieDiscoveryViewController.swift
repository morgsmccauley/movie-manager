//
//  MovieCollecitionViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 22/02/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDiscoveryViewController: UIViewController, MovieViewControllerProtocol, MovieManagerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!;
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!;
    @IBOutlet weak var movieGroupSelector: UIButton!
    @IBOutlet weak var menuBubbleView: UIView!
    @IBAction func onMovieGroupSelectorPressed(_ sender: Any) {
        if (menuBubbleView.transform == .identity) {
            closeMenuBubble();
        } else {
            openMenuBubble();
        }
    }
    @IBAction func onMenuItemPressed(_ sender: UIButton) {
        if let pressedButton = sender.titleLabel?.text {
            currentMovieGroup = pressedButton;
            currentPageRequestNumber = 1;
            movieResults = [];
            menuItemMap?[pressedButton]?(currentPageRequestNumber);
            movieGroupSelector.setTitle(pressedButton, for: UIControlState.normal);
            closeMenuBubble();
        }
    }
    
    var imageCache = NSCache<AnyObject, UIImage>();
    
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
    var menuItemMap: [String: (Int) -> ()]?;
    var currentMovieGroup: String = "";
    
    let minHeaderHeight: CGFloat = 0;
    let maxHeaderHeight: CGFloat = 158;
    var previousScrollOffset:CGFloat = 0;
    var isInitialScroll = true; //to prevent header changing from initial hide status bar scroll
    
    func movieFetchComplete(movies: [Movie]) {
        fetchInProgress = false;
        self.movieResults.append(contentsOf: movies);
    }
    
    func openMenuBubble() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [], animations: {
            self.movieGroupSelector.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi);
            self.menuBubbleView.transform = .identity;
        });
    }
    
    func closeMenuBubble() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [], animations: {
            self.menuBubbleView.transform = CGAffineTransform(scaleX: 0, y: 0);
            self.movieGroupSelector.imageView?.transform = .identity
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.movieGroupSelector.semanticContentAttribute = .forceRightToLeft;
        
        closeMenuBubble();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        menuItemMap = [
            "Popular": movieManager.fetchPopularMovies,
            "Top Rated": movieManager.fetchTopRatedMovies,
            "Coming Soon": movieManager.fetchComingSoonMovies
        ];
        
        movieManager.delegate = self;
        setUpCollectionViewLayout();
        currentMovieGroup = "Popular"; //use outlet to set this value
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
        cell.moviePoster.image = nil;
        getMoviePoster(movieIndex: indexPath.row, cell: cell);

        return cell;
    }
    
    func getMoviePoster(movieIndex: Int, cell: MovieCollectionViewCell) {
        let posterPath = movieResults[movieIndex].posterPath;
        if let poster = imageCache.object(forKey: posterPath as AnyObject) {
            DispatchQueue.main.async {
                cell.moviePoster.image = poster;
            }
            return;
        }
        
        movieManager.fetchImage(path: posterPath) { poster in
            DispatchQueue.main.async {
                cell.moviePoster.image = poster;
            }
            self.imageCache.setObject(poster!, forKey: posterPath as AnyObject)
        }
    }
}

extension MovieDiscoveryViewController: UICollectionViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "MovieDetailSegue" else { return; }
        
        if let cell = sender as? MovieCollectionViewCell,
            let indexPath = self.collectionView!.indexPath(for: cell),
            let destination = segue.destination as? MovieDetailViewController,
            let _ = destination.view { //force view to load outlets
            
            let movie = movieResults[(indexPath as NSIndexPath).row];
            destination.poster.image = cell.moviePoster.image;
            destination.movie = movie;
            self.getRuntime(for: movie, passTo: destination);
            self.getBackdrop(for: movie, passTo: destination);
            self.getCast(for: movie, passTo: destination);
            self.getReviews(for: movie, passTo: destination);
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.menuBubbleView.transform == .identity) { //this will break if the user clears the button when is scrolling. only want to initiate when user is stationary, opens, then scrolls
            closeMenuBubble();
        }
        
        if (isInitialScroll) {
            isInitialScroll = false;
            return;
        }
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        let isAtBottom = scrollView.contentOffset.y > absoluteBottom / 2;
        
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
        fetchInProgress = true;
        
        currentPageRequestNumber = currentPageRequestNumber + 1;
        menuItemMap?[currentMovieGroup]?(currentPageRequestNumber);
    }
}
