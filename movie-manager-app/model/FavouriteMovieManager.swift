//
//  FavouriteMovieManager.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 17/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import Foundation;
import CoreData;
import UIKit;

class FavourtieMovieManager {
    let appDelegate: AppDelegate!;
    let context: NSManagedObjectContext!;
    let entity: NSEntityDescription!;
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate;
        context = appDelegate.persistentContainer.viewContext;
        entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: context);
    }
    
    public func isSaved(movieId: Int) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity");
        request.returnsObjectsAsFaults = false;
        
        if let result = try? context.fetch(request) {
            for object in result as! [NSManagedObject] {
                if object.value(forKey: "id") as! Int == movieId {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    //add private func to iterate over context, pass condition to match and function to execute if successful
    public func remove(movieId: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity");
        request.returnsObjectsAsFaults = false;
        
        if let result = try? context.fetch(request) {
            for object in result as! [NSManagedObject] {
                if object.value(forKey: "id") as! Int == movieId {
                    print("removed \(object.value(forKey: "title")!)");
                    context.delete(object)
                }
            }
        }
    }
    
    public func save(movie: Movie) {
        let newMovie = NSManagedObject(entity: entity!, insertInto: context);
        
        newMovie.setValue(movie.id, forKey: "id");
        newMovie.setValue(movie.title, forKey: "title");
        newMovie.setValue(movie.backdropPath, forKey: "backdropPath");
        newMovie.setValue(movie.posterPath, forKey: "posterPath");
        newMovie.setValue(movie.rating, forKey: "rating");
        newMovie.setValue(movie.releaseDate, forKey: "releaseDate");
        newMovie.setValue(movie.overview, forKey: "overview");
        newMovie.setValue(movie.runtime, forKey: "runtime");
        
        do {
            try context.save();
            print("saved \(movie.title) \(movie.id)");
        } catch {
            print("Failed saving movie")
        }
    }
    
    public func fetchSaved() -> [Movie] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity");
        request.returnsObjectsAsFaults = false;

        var savedMovies: [Movie] = [];
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                savedMovies.append(entityToMovie(data));
            }
        } catch {
            print("Failed to fetch favourite movies")
            return [];
        }
        
        return savedMovies;
    }
    
    private func entityToMovie(_ data: NSManagedObject) -> Movie {
        let id = data.value(forKey: "id") as! Int,
        overview = data.value(forKey: "overview") as! String,
        rating = data.value(forKey: "rating") as! String,
        releaseDate = data.value(forKey: "releaseDate") as! String,
        title = data.value(forKey: "title") as! String,
        posterPath = data.value(forKey: "posterPath") as! String,
        backdropPath = data.value(forKey: "backdropPath") as! String,
        runtime = data.value(forKey: "runtime") as! String;
        
        return Movie(id: id, title: title, posterPath: posterPath, backdropPath: backdropPath, releaseDate: releaseDate, overview: overview, rating: rating, runtime: runtime);
    }
}
