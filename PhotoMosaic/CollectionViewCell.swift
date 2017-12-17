//
//  CollectionViewCell.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/16/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit
import UIScreenExtension

class CollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var model: CellModel! {
        didSet {
            isScaleEnabled = true
            isSettingNewModel = true
            
            let image = model.image
            imageView.image = image
            
            if model.zoomScale == nil {
                if image.size.width > image.size.height {
                    model.zoomScale = image.size.width / image.size.height
                } else {
                    model.zoomScale = image.size.height / image.size.width
                }
                print("Set initial model zoom scale")
            }
            print("Zoom scale: \(model.zoomScale!)")
            scrollView.zoomScale = model.zoomScale!
            
            if model.contentOffset == nil {
                let x: CGFloat = (imageView.frame.size.width - scrollView.bounds.width) / 2
                let y: CGFloat = (imageView.frame.size.height - scrollView.bounds.height) / 2
                model.contentOffset = CGPoint(x: x, y: y)
                print("Set initial model content offset")
            }
            print("Content offset: \(model.contentOffset!)")
            scrollView.contentOffset = model.contentOffset!
            
            isSettingNewModel = false
        }
    }
    
    private var isSettingNewModel: Bool = false
    var isScaleEnabled: Bool = false {
        didSet {
            scrollView.isScrollEnabled = isScaleEnabled
            scrollView.minimumZoomScale = isScaleEnabled ? 1.0 : scrollView.zoomScale
            scrollView.maximumZoomScale = isScaleEnabled ? 10.0 : scrollView.zoomScale
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !isSettingNewModel {
            model.zoomScale = scrollView.zoomScale
            print("Did zoom: \(model.zoomScale!)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isSettingNewModel {
            model.contentOffset = scrollView.contentOffset
            print("Did scroll: \(model.contentOffset!)")
        }
    }
    
}
