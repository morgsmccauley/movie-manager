//
//  MovieViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/08/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
  
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    let movieManager = MovieManager();
    
    var cast: [Actor] = [] {
        didSet {
            DispatchQueue.main.async {
                self.castCollectionView!.reloadData();
            }
        }
    }
    
    var movie: Movie! {
        didSet {
            self.name.text = movie.title;
            self.overview.text = movie.overview;
            self.releaseDate.text = movie.releaseDate;
            self.runtime.text = movie.runtime;
        }
    }
}

extension MovieDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cast.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCollectionViewCell", for: indexPath) as! CastCollectionViewCell;
        let actor = cast[(indexPath as NSIndexPath).row];
        
        cell.name.text = actor.name;
        getProfileImage(actorIndex: (indexPath as NSIndexPath).row, cell);
        
        return cell;
    }
    
    func getProfileImage(actorIndex: Int, _ cell: CastCollectionViewCell) {
        let actor = cast[actorIndex];
        if let profileImage = actor.profileImage {
            cell.profileImage.image = profileImage;
        } else {
            movieManager.fetchImage(path: actor.profileImagePath) { [weak self] profileImage in
                if let profileImage = profileImage {
                    DispatchQueue.main.async {
                        cell.profileImage.image = profileImage;
                    }
                    self?.cast[actorIndex].profileImage = profileImage;
                    //this will trigger didset causing the view to reload / flickering
                }
            }
        }
    }
}
