//
//  HttpHandler.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 5/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import Foundation

class HTTPHandler {
    static func getJson(urlString: String, completionHandler: @escaping (Data?) -> (Void)) {
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            if let data = data {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                print("request for URL: \(url!) completed with code: \(statusCode)")
                if (statusCode == 200) {
                    completionHandler(data as Data)
                }
            } else if let error = error {
                print("***There was an error making the HTTP request***")
                print(error.localizedDescription)
                completionHandler(nil)
            }
        }
        task.resume()
    }
}
