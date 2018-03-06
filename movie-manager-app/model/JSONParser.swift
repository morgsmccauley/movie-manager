//
//  JsonParser.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 5/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import Foundation

class JSONParser {
    static func parse(_ data: Data) -> [String: AnyObject]? {
        let options = JSONSerialization.ReadingOptions()
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject];
            return json!
        } catch (let parseError){
            print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"");
        }
        
        return nil
    }
}
