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
private let DEFAULT_MOVIE_STRING_VALUE = "Undefined";
private let DEFAULT_MOVIE_INT_VALUE = -1;

class MovieManager {
    
    public var delegate: MovieManagerDelegate?;
    
    public func fetchPopularMovies(page: Int) {
        let popularRequestEndpoint = "https://api.themoviedb.org/3/movie/popular?api_key=\(API_KEY)&language=en-US&page=\(String(page))";
        makeMovieRequest(with: popularRequestEndpoint);
    }
    
    public func fetchTopRatedMovies(page: Int) {
        let popularRequestEndpoint = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(API_KEY)&language=en-US&page=\(String(page))";
        makeMovieRequest(with: popularRequestEndpoint);
    }
    
    public func fetchComingSoonMovies(page: Int) {
        let popularRequestEndpoint = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(API_KEY)&language=en-US&page=\(String(page))";
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

    public func fetchImage(path: String, completionHandler: @escaping ((UIImage?) -> ())) {
        let imageEndpoint = "https://image.tmdb.org/t/p/w500\(path)";
        
        HTTPHandler.getJson(urlString: imageEndpoint) { data in
            completionHandler(UIImage(data: data!))
        }
    }
    
    public func appendMovieDetails(movie: Movie, completionHandler: @escaping ((Movie?) -> ())) {
        let movieDetailsEndpoint = "https://api.themoviedb.org/3/movie/\(movie.id)?api_key=\(API_KEY)&language=en-US";
        
        HTTPHandler.getJson(urlString: movieDetailsEndpoint) { [weak self] data in
            let movieWithDetails = self?.mapMovieDetails(movie, JSONParser.parse(data!)!);
            completionHandler(movieWithDetails);
        }
    }

    private func makeMovieRequest(with endpoint: String) {
        HTTPHandler.getJson(urlString: endpoint) { [weak self] data in
            guard let movieJson = JSONParser.parse(data!)!["results"] as? [[String: AnyObject]] else { return; }
            
            let movieResults = self?.createMovieListFrom(json: movieJson);
            self?.delegate?.movieFetchComplete(movies: movieResults!)
        }
    }

    private func createMovieListFrom(json movieJsonArray: [[String: AnyObject]]) -> [Movie] {
        var movies: [Movie] = [];

        for movieObject in movieJsonArray {
            movies.append(mapMovie(movieObject));
        }

        return movies;
    }
    
    private func mapMovie(_ object: [String: AnyObject]) -> Movie {
        let id = object["id"] as! Int,
        title = object["title"] as! String,
        posterPath = object["poster_path"] as! String,
        backdropPath = object["backdrop_path"] as! String,
        releaseDate = object["release_date"] as! String,
        overview = object["overview"] as! String,
        popularity = object["popularity"] as? String ?? DEFAULT_MOVIE_STRING_VALUE;
        
        return Movie(id: id, title: title, posterPath: posterPath, backdropPath: backdropPath, releaseDate: releaseDate, overview: overview, popularity: popularity);
    }
    
    private func mapMovieDetails(_ movie: Movie, _ object: [String: AnyObject]) -> Movie {
        let genres = object["genres"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        company = object["production_companies"] as? String ?? DEFAULT_MOVIE_STRING_VALUE, //these are lists
        budget = String(describing: object["budget"]!),
        runtime = String(describing: object["runtime"]!);
        
        var movieWithDetails = movie;
        movieWithDetails.genres = genres;
        movieWithDetails.company = company;
        movieWithDetails.budget = budget;
        movieWithDetails.runtime = runtime;
        
        return movieWithDetails;
    }
}
