//
//  Cast.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 9/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import Foundation
import UIKit

struct Actor {
    let name: String;
    let character: String;
    let profileImagePath: String;
    
    var profileImage: UIImage? = nil;

    init(name: String, character: String, profileImagePath: String) {
        self.name = name;
        self.character = character;
        self.profileImagePath = profileImagePath;
    }
}
