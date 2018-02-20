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
private let MOVIE_VIEW_SEGUE_IDENTIFIER = "MovieViewSegue";

//split and extend
class MovieCollectionViewController: UICollectionViewController, MovieManagerDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!;
    
    let movieManager = MovieManager();

    func movieFetchComplete(movies: [Movie]) {
        self.movieResults = movies;
    }

    var movieResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView!.reloadData();
            }
        }
    };
    
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieResults.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COLLECTION_VIEW_CELL_IDENTIFIER, for: indexPath) as! MovieCollectionViewCell;
        
        getMoviePoster(movieIndex: indexPath.row, cell: cell)
        return cell;
    }
    
    private func getMoviePoster(movieIndex: Int, cell: MovieCollectionViewCell) {
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
    
    //what does this do?
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: COLLECTION_VIEW_HEADER_IDENTIFIER, for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView();
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == MOVIE_VIEW_SEGUE_IDENTIFIER else { return; }

        if let cell = sender as? MovieCollectionViewCell,
           let indexPath = self.collectionView!.indexPath(for: cell),
           let destination = segue.destination as? MovieViewController {

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

