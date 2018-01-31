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
    
    public var delegate: MovieManagerDelegate?;
    
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

    private var resultsTotal: Int = -1;
    private var movieResults: [Movie] = [] {
        didSet {
            let allRequestsComplete = movieResults.count == resultsTotal;
            if (allRequestsComplete) {
                print("return results")
                delegate?.movieFetchComplete(movies: movieResults);

                resetMovieFetchParameters();
            }
        }
    }

    private func resetMovieFetchParameters() {
        resultsTotal = -1;
        movieResults = [];
    }

    private func addMovieDetails(movies: [Movie]) {
        for movie in movies {
            let movieDetailsEndpoint = "https://api.themoviedb.org/3/movie/\(movie.id)?api_key=\(API_KEY)&language=en-US";

            guard let movieDetailsUrl = URL(string: movieDetailsEndpoint) else {
                print("ERROR: cannot convert endpoint to url");
                delegate?.movieFetchComplete(movies: []);

                return;
            }

            URLSession.shared.dataTask(with: movieDetailsUrl, completionHandler: { [weak self] (data, response, error) in
                if let data = data,
                   let jsonResponse = try? JSONSerialization.jsonObject(with: data) as! [String: AnyObject],
                   let movie = self?.setFullDetailsFor(movie: movie, with: jsonResponse) {

                    self?.movieResults.append(movie);
                } else {
                    self?.delegate?.movieFetchComplete(movies: []);
                }
            }).resume();
        }
    }

    private func setFullDetailsFor(movie: Movie, with data: [String: AnyObject]) -> Movie {
        let fullDetailMovie = movie;

        if let genres = parseAndFormat(dataObject: data["genres"]) {
            fullDetailMovie.genres = genres;
        }

        if let company = parseAndFormat(dataObject: data["production_companies"]) {
            fullDetailMovie.company = company;
        }

        if let budget = data["budget"] {
            fullDetailMovie.budget = String(describing: budget);
        }

        if let runtime = data["runtime"] {
            fullDetailMovie.runtime = String(describing: runtime);
        }

        return fullDetailMovie;
    }

    private func parseAndFormat(dataObject: AnyObject?) -> String? {
        var formattedString: String = "";

        if let jsonMap = dataObject as? [AnyObject] {
            for  object in jsonMap {
                if let jsonObject = object as? [String: AnyObject] {
                    formattedString += "\(jsonObject["name"]!) - ";
                }
            }
        }

        return formattedString;
    }

    private func makeWebRequest(endpoint: URL, completionHandler: String) {

    }

    private func makeMovieRequest(with endpoint: String) {
        let endpointUrl = URL.init(string: endpoint)!;
        URLSession.shared.dataTask(with: endpointUrl, completionHandler: { [weak self] (data, response, error) in
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject],
                let movieJson = jsonResponse["results"] as? [[String: AnyObject]] else {
                    print("ERROR: could not covert search response to JSON");
                    self?.delegate?.movieFetchComplete(movies: [])

                    return;
            }

            if let parsedMovieResults = self?.setInitialMovieDataFrom(json: movieJson) {
                self?.resultsTotal = parsedMovieResults.count
                self?.addMovieDetails(movies: parsedMovieResults);

                return;
            }

            print("ERROR: failed to parse movie results");
            self?.delegate?.movieFetchComplete(movies: []);
        }).resume();
    }

    private func setInitialMovieDataFrom(json movieJson: [[String: AnyObject]]) -> [Movie] {
        var movies: [Movie] = [];

        for movie in movieJson {
            movies.append(Movie(id: movie["id"] as? Int ?? -1,
                                title: movie["title"] as? String ?? "",
                                posterPath: movie["poster_path"] as? String ?? "",
                                backdropPath: movie["backdrop_path"] as? String ?? "",
                                releaseDate: movie["release_date"] as? String ?? "",
                                overview: movie["overview"] as? String ?? "",
                                popularity: String(describing: movie["popularity"])));
        }

        return movies;
    }
}
