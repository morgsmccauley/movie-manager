//
//  MovieDiscoveryHeaderView.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 6/03/18.
//  Copyright © 2018 Morgan McCauley. All rights reserved.
//

import UIKit

class MovieDiscoveryHeaderView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
