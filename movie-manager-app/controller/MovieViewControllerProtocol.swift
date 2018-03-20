//
//  MovieViewControllerProtocol.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 20/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import Foundation

protocol MovieViewControllerProtocol {
    var movieManager: MovieManager { get };
    
    func getPoster(for movie: Movie, passTo destination: MovieDetailViewController);
    func getReviews(for movie: Movie, passTo destination: MovieDetailViewController);
    func getCast(for movie: Movie, passTo destination: MovieDetailViewController);
    func getBackdrop(for movie: Movie, passTo destination: MovieDetailViewController);
    func getBackdrop(for movie: Movie, passTo row: MovieTableViewCell);
    func getRuntime(for movie: Movie, passTo destination: MovieDetailViewController);
}

extension MovieViewControllerProtocol {
    func getPoster(for movie: Movie, passTo destination: MovieDetailViewController) {
        movieManager.fetchImage(path: movie.posterPath) { poster in
            DispatchQueue.main.async {
                destination.poster.image = poster;
            }
        }
    }
    
    func getReviews(for movie: Movie, passTo destination: MovieDetailViewController) {
        movieManager.fetchReviews(movieId: movie.id) { reviews in
            destination.reviews = reviews!;
        }
    }
    
    func getCast(for movie: Movie, passTo destination: MovieDetailViewController) {
        movieManager.fetchCast(movieId: movie.id) { actors in
            destination.cast = actors!;
        }
    }
    
    func getBackdrop(for movie: Movie, passTo destination: MovieDetailViewController) {
        movieManager.fetchImage(path: movie.backdropPath) { backdrop in
            DispatchQueue.main.async {
                destination.backdrop.image = backdrop;
            }
        }
    }
    
    func getBackdrop(for movie: Movie, passTo row: MovieTableViewCell) {
        movieManager.fetchImage(path: movie.backdropPath) { backdrop in
            DispatchQueue.main.async {
                row.backdrop.image = backdrop;
            }
        }
    }
    
    func getRuntime(for movie: Movie, passTo destination: MovieDetailViewController) {
        movieManager.fetchRuntime(movie: movie) { runtime in
            DispatchQueue.main.async {
                destination.runtime.text = runtime!;
            }
        }
    }
}

