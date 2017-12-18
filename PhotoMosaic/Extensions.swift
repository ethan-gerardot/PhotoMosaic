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
    
    func contentSize(for scrollViewSize: CGSize) -> CGSize {
        let aspectRatio = size.width / size.height
        
        var width = scrollViewSize.width
        var height = width / aspectRatio
        
        if (height > scrollViewSize.height) {
            height = scrollViewSize.height;
            width = height * aspectRatio;
        }
        
        let scale: CGFloat
        if size.width > size.height {
            scale = size.width / size.height
        } else {
            scale = size.height / size.width
        }
        
        return CGSize(width: width * scale, height: height * scale);
    }
    
}

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat = 8.0) {
        let maskShape = CAShapeLayer()
        maskShape.bounds = frame
        maskShape.position = center
        
        let cornerRadii = CGSize(width: radius, height: radius)
        maskShape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii).cgPath
        
        layer.mask = maskShape
    }
    
}
