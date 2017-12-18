//
//  ImageLoader.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/18/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit

class ImageLoader {
    
    static private let baseDirectory = "DefaultImages"
    static private let subdirectoriesList = ["Light", "Medium", "Dark"]
    
    static func loadDefaultImages() -> [UIImage] {
        var images: [UIImage] = []
        
        let subdirectories = subdirectoriesList.map { "\(baseDirectory)/\($0)" }
        for subdir in subdirectories {
            var imageIndex = 1
            var image = ImageLoader.image(in: subdir, index: imageIndex)
            while image != nil  {
                images.append(image!)
                imageIndex += 1
                image = ImageLoader.image(in: subdir, index: imageIndex)
            }
        }
        
        return images
    }
    
    private static func image(in directory: String, index: Int) -> UIImage? {
        guard let path = Bundle.main.path(forResource: "\(index)", ofType: "jpg", inDirectory: directory) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
}
