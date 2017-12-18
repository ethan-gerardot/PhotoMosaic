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
    let contentSize: CGSize
    var zoomScale: CGFloat?
    var contentOffset: CGPoint?
    
    convenience init(image: UIImage, cellSize: CGSize) {
        self.init(image: image, contentSize: image.contentSize(for: cellSize))
    }
    
    init(image: UIImage, contentSize: CGSize) {
        self.image = image
        self.contentSize = contentSize
    }
    
    var description: String {
        return "image: \(image)\ncontentSize: \(contentSize)\(zoomScale != nil ? "\nzoomScale: \(zoomScale!)" : "")\(contentOffset != nil ? "\ncontentOffset: \(contentOffset!)" : "")"
    }
    
}
