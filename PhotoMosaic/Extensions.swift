//
//  Extensions.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/17/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit
import UIScreenExtension

extension CGFloat {
    
    static func from(_ string: String?) -> CGFloat {
        guard let string = string, let number = NumberFormatter().number(from: string) else {
            return 0
        }
        
        return CGFloat(number.floatValue)
    }
    
}

extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
}
