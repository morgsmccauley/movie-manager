//
//  movieManager.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit


class MovieManager: MoviePosterDelegate {
    
    private let apiKey = "e2ee42fbd9d45fd431771c42d0bda8cd";
    
    //return errors to handler - should it be option array or optional items in array
    func fetchMovies(withTitle title: String, movieHandler: @escaping (([Movie]?) -> ())){
        var matchedMovies: [Movie] = [];
        
        guard let escapedTitle = title.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            movieHandler(nil);
            return;
        }
        
        //when bottom is reached query page 2 and append to original array
        let searchRequest = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(escapedTitle)&page=1&include_adult=false";
        
        guard let movieSearchURL = URL(string: searchRequest) else {
            movieHandler(nil);
            return;
        }
        
        var _ =  URLSession.shared.dataTask(with: movieSearchURL) { (data, response, error) in
            //throw on error
            let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject];
            
            let rawMovieSearch = jsonResponse!["results"] as! [[String: AnyObject]];
            
            for movie in rawMovieSearch {
                let title = movie["title"] as! String;
                
                if let posterPath = movie["poster_path"] as? String {
                    matchedMovies.append(Movie(title: title, posterPath: posterPath, moviePosterDelegate: self));
                } else {
                    matchedMovies.append(Movie(title: title, posterPath: "", moviePosterDelegate: nil));
                }
            }
            
            movieHandler(matchedMovies);
        }.resume();
    }
    
    func fetchMoviePosterWith(posterPath: String, completionHandler: @escaping ((UIImage?) -> ())) {
        
        let posterRequestString = "https://image.tmdb.org/t/p/w500\(posterPath)";
        
        guard let posterRequestUrl = URL(string: posterRequestString) else {
            completionHandler(nil);
            return;
        }
        
        var _ = URLSession.shared.dataTask(with: posterRequestUrl) { (data, response, error) in

            if let image = UIImage(data: data!) {
                completionHandler(image);
            } else {
                completionHandler(nil);
            }
        }.resume();
    }
}
