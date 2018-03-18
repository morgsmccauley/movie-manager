//
//  MovieTabBarController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 18/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieTabBarController: UITabBarController {
    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
}
