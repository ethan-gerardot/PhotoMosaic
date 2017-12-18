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
            isSettingNewModel = true
            let wasScaleEnabled = isScaleEnabled
            isScaleEnabled = true
            
            scrollView.contentSize = model.contentSize
            scrollView.zoomScale = 1.0
            
            imageView.image = model.image
            imageView.frame = CGRect(origin: .zero, size: model.contentSize)
            
            if let zoomScale = model.zoomScale {
                scrollView.zoomScale = zoomScale
            }
            
            if let contentOffset = model.contentOffset {
                scrollView.contentOffset = contentOffset
            }
            
            isScaleEnabled = wasScaleEnabled
            isSettingNewModel = false
        }
    }
    var editAction: (()->())?
    
    private var isSettingNewModel: Bool = false
    var isScaleEnabled: Bool = false {
        didSet {
            scrollView.isScrollEnabled = isScaleEnabled
            scrollView.minimumZoomScale = isScaleEnabled ? 1.0 : scrollView.zoomScale
            scrollView.maximumZoomScale = isScaleEnabled ? 10.0 : scrollView.zoomScale
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    private var imageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.addSubview(imageView)
        scrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !isSettingNewModel {
            model.zoomScale = scrollView.zoomScale
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isSettingNewModel {
            model.contentOffset = scrollView.contentOffset
        }
    }
    
    @IBAction func editButtonAction() {
        editAction?()
    }
}
