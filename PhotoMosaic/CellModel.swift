//
//  CellModel.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/17/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit

class CellModel {
    
    let image: UIImage
    var zoomScale: CGFloat?
    var contentOffset: CGPoint?
    
    init(image: UIImage) {
        self.image = image
    }
    
}
