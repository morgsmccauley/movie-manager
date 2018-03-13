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
    
    public func fetchCast(movieId: Int, completionHandler: @escaping (([Actor]?) -> ())) {
        let movieCastEndpoint = "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(API_KEY)&language=en-US";
        
        HTTPHandler.getJson(urlString: movieCastEndpoint) { [weak self] data in
            guard let castJson = JSONParser.parse(data!)!["cast"] as? [[String: AnyObject]] else { return; }
            completionHandler(self?.createActorListFrom(json: castJson));
        }
    }
    
    public func fetchReviews(movieId: Int, completionHandler: @escaping (([Review]?) -> ())) {
        let movieReviewEndpoint = "https://api.themoviedb.org/3/movie/\(movieId)/reviews?api_key=\(API_KEY)&language=en-US&page=1";
        
        HTTPHandler.getJson(urlString: movieReviewEndpoint) { [weak self] data in
            guard let reviewJson = JSONParser.parse(data!)!["results"] as? [[String: AnyObject]] else { return; }
            completionHandler(self?.createReviewListFrom(json: reviewJson));
        }
    }
    
    private func createReviewListFrom(json reviewJson: [[String: AnyObject]]) -> [Review] {
        var reviewList: [Review] = [];
        for review in reviewJson {
            reviewList.append(mapReview(review));
        }
        
        return reviewList;
    }
    
    private func mapReview(_ object: [String: AnyObject]) -> Review {
        let author = object["author"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        content = object["content"] as? String ?? DEFAULT_MOVIE_STRING_VALUE;
        
        return Review(author: author, content: content);
    }
    
    private func createActorListFrom(json castJson: [[String: AnyObject]]) -> [Actor] {
        var actorList: [Actor] = [];
        for actorJson in castJson {
            actorList.append(mapActor(actorJson))
        }
        
        return actorList;
    }
    
    private func mapActor(_ object: [String: AnyObject]) -> Actor {
        let name = object["name"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        character = object["character"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        profileImagePath = object["profile_path"] as? String ?? DEFAULT_MOVIE_STRING_VALUE;
        
        return Actor(name: name, character: character, profileImagePath: profileImagePath);
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
        let id = object["id"] as? Int ?? DEFAULT_MOVIE_INT_VALUE,
        title = object["title"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        posterPath = object["poster_path"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        backdropPath = object["backdrop_path"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        releaseDate = getYearFromFull(date: object["release_date"] as! String) ?? DEFAULT_MOVIE_STRING_VALUE,
        overview = object["overview"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        rating = "\(String(describing: object["vote_average"] as! NSNumber)) / 10";
        
        return Movie(id: id, title: title, posterPath: posterPath, backdropPath: backdropPath, releaseDate: releaseDate, overview: overview, rating: rating);
    }
    
    private func getYearFromFull(date: String) -> String? {
        guard let dashIndex = date.index(of: "-") else { return nil; }
        return String(date[...date.index(before: dashIndex)]);
    }
    
    private func mapMovieDetails(_ movie: Movie, _ object: [String: AnyObject]) -> Movie {
        let genres = object["genres"] as? String ?? DEFAULT_MOVIE_STRING_VALUE,
        company = object["production_companies"] as? String ?? DEFAULT_MOVIE_STRING_VALUE, //these are lists
        budget = String(describing: object["budget"]!),
        runtime = convertMinsToHourMinString(object["runtime"] as? Double) ?? DEFAULT_MOVIE_STRING_VALUE;
        
        var movieWithDetails = movie;
        movieWithDetails.genres = genres;
        movieWithDetails.company = company;
        movieWithDetails.budget = budget;
        movieWithDetails.runtime = runtime;
        
        return movieWithDetails;
    }
    
    private func convertMinsToHourMinString(_ runtime: Double?) -> String? {
        guard let runtime = runtime else { return nil; }
        
        let hours = floor(runtime / 60);
        let mins = runtime - (hours * 60);
        
        return "\(Int(hours))hr \(Int(mins))min";
    }
}
