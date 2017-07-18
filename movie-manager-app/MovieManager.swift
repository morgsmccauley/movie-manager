//
//  movieManager.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation

class MovieManager {
    
    private let apiKey = "e2ee42fbd9d45fd431771c42d0bda8cd";
    
    //return errors to handler - should it be option array or optional items in array
    func fetchMovies(withTitle title: String, handler: @escaping (([Movie]?) -> ())){
        
        var matchedMovies: [Movie] = [];
        
        //need to encode title, need to return if it is not possible to
        let request = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(title)&page=1&include_adult=false";
        
        //let defaultSession = URLSession(configuration: URLSessionConfiguration.default);
        guard let searchURL = URL(string: request) else {
            
            handler(nil);
            return;
        }
        
        
        //check and make sure its on right queue
        var _ =  URLSession.shared.dataTask(with: searchURL) { (data, Response, error) in
            
            print("movie manager");
            print(Thread.isMainThread);
            
            //throw on error
            let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject];
            
            let rawMovieSearch = jsonResponse!["results"] as! [[String: AnyObject]];
            
            for movie in rawMovieSearch {
                
                let movieTitle = movie["title"] as! String;
//                print(movieTitle);
                matchedMovies.append(Movie(title: movieTitle));
            }
            
            handler(matchedMovies);
            
        }.resume();
    }
    
    init() {
        
    }
}
