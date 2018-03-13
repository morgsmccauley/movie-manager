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
    var imageCache = NSCache<AnyObject, UIImage>();
    
    var cast: [Actor] = [] {
        didSet {
            DispatchQueue.main.async {
                self.castCollectionView!.reloadData();
            }
        }
    }
    
    var reviews: [Review] = [] {
        didSet {
            DispatchQueue.main.async {
                self.reviewTableView!.reloadData();
            }
        }
    }
    
    var movie: Movie! {
        didSet {
            self.name.text = movie.title;
            self.overview.text = movie.overview;
            self.releaseDate.text = movie.releaseDate;
            self.runtime.text = movie.runtime;
            self.rating.text = movie.rating;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        poster.dropShadow();
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
        getProfileImage(actor, cell);
        
        return cell;
    }
    
    func getProfileImage(_ actor: Actor, _ cell: CastCollectionViewCell) {
        if let profileImage = imageCache.object(forKey: actor.profileImagePath as AnyObject) {
            cell.profileImage.image = profileImage;
            return;
        }
        
        movieManager.fetchImage(path: actor.profileImagePath) { [weak self] profileImage in
            if let profileImage = profileImage {
                DispatchQueue.main.async {
                    cell.profileImage.image = profileImage;
                }
                self?.imageCache.setObject(profileImage, forKey: actor.profileImagePath as AnyObject);
            }
        }
    }
}

extension MovieDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell;
        let review = reviews[(indexPath as NSIndexPath).row];
        
        row.author.text = review.author;
        row.content.text = review.content;
        
        return row;
    }
    
    
}

extension UIImageView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
