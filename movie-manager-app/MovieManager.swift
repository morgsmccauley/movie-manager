//
//  movieManager.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 8/07/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit

protocol MovieManagerDelegate {
    
    func movieFetchComplete(movies: [Movie]);
}

private let API_KEY = "e2ee42fbd9d45fd431771c42d0bda8cd";

class MovieManager{
    
    var delegate: MovieManagerDelegate?;
    var imageFetchCallback: ((_ image: UIImage, _ cellIndexPath: IndexPath) -> Void)?;
    
    public func fetchPopularMovies() {
        
        let popularRequestEndpoint = "https://api.themoviedb.org/3/movie/popular?api_key=\(API_KEY)&language=en-US&page=1";
        makeMovieRequest(with: popularRequestEndpoint);
    }
    
    public func fetchMoviesFor(query: String) {

        guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("ERROR: Cannot escape query for movie search");
            delegate?.movieFetchComplete(movies: []);

            return;
        }
        
        let movieSearchEndpoint = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&language=en-US&query=\(escapedQuery)&page=1&include_adult=false";
        makeMovieRequest(with: movieSearchEndpoint);
    }
    
    public func fetchMultiSearchFor(query: String) {
        
        guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("ERROR: Cannot escape query for multi search");
            delegate?.movieFetchComplete(movies: []);

            return;
        }
        
        let multiSearchEndpoint = "https://api.themoviedb.org/3/search/multi?api_key=\(API_KEY)&language=en-US&query=\(escapedQuery)&page=1&include_adult=false";
        makeMovieRequest(with: multiSearchEndpoint);
    }
    
    private func makeMovieRequest(with endpoint: String) {
        
        //should be able to trust url
        guard let endpointUrl = URL(string: endpoint) else {
            print("ERROR: cannot convert endpoint to url");
            delegate?.movieFetchComplete(movies: []);

            return;
        }
        
        let task =  URLSession.shared.dataTask(with: endpointUrl) { [weak self] (data, response, error) in
            
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject],
                  let movieJson = jsonResponse["results"] as? [[String: AnyObject]] else {
                    print("ERROR: could not covert response to JSON");
                    self?.delegate?.movieFetchComplete(movies: []);

                    return;
            }
            
            let parsedMovies = self?.getMovieDataFrom(json: movieJson);
            
            self?.delegate?.movieFetchComplete(movies: parsedMovies!);
        }
        task.resume();
    }
    
    private func getMovieDataFrom(json movieJson: [[String: AnyObject]]) -> [Movie] {
        
        var movies: [Movie] = [];
        
        for movie in movieJson {
            
            let id = movie["id"] as? Int ?? -1;
            let title = movie["title"] as? String ?? "";
            let posterPath = movie["poster_path"] as? String ?? "";
            let backdropPath = movie["backdrop_path"] as? String ?? "";
            let releaseDate = movie["release_date"] as? String ?? ""
            let overview = movie["overview"] as? String ?? "";
            let popularity = movie["popularity"] as? Int ?? -1;
            
            movies.append(Movie(id: id,
                                title: title,
                                posterPath: posterPath,
                                backdropPath: backdropPath,
                                releaseDate: releaseDate,
                                overview: overview,
                                popularity: popularity));
        }
        
        return movies;
    }
    
    public func fetchFullDetails() {
        
    }
    
    public func fetchImage(path: String, completionHandler: @escaping ((UIImage?) -> ())) {
        
        let imageEndpoint = "https://image.tmdb.org/t/p/w500\(path)";
        
        guard let endpointUrl = URL(string: imageEndpoint) else {
            return;
        }
        
        let task = URLSession.shared.dataTask(with: endpointUrl) { (data, response, error) in
            
            let image = UIImage(data: data!)
            completionHandler(image)
        }
        task.resume();
    }
}
