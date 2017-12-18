//
//  EditImageViewController.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/17/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit

protocol EditImageViewControllerDelegate: class {
    
    func didFinishEditingImage(_ image: UIImage, at indexPath: IndexPath)
    
}

class EditImageViewController: UIViewController {

    weak var delegate: EditImageViewControllerDelegate?
    
    var item: (image: UIImage, indexPath: IndexPath)!
    @IBOutlet private weak var imageView: UIImageView!
    
    var contrastFilter: CIFilter!
    var brightnessFilter: CIFilter!
    var context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = item.image
        
        context = CIContext(options: nil)
        brightnessFilter = CIFilter(name: "CIColorControls")
        contrastFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(0, forKey: "inputBrightness")
        contrastFilter.setValue(1, forKey: "inputContrast")
        updateInputImage(for: brightnessFilter)
        updateInputImage(for: contrastFilter)
    }
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness")
        updateImage(with: brightnessFilter.outputImage!)
        updateInputImage(for: contrastFilter)
    }
    
    @IBAction func contrastSliderValueChanged(_ sender: UISlider) {
        contrastFilter.setValue(NSNumber(value: sender.value), forKey: "inputContrast")
        updateImage(with: contrastFilter.outputImage!)
        updateInputImage(for: brightnessFilter)
    }
    
    @IBAction func cancelAction() {
        dismiss(animated: true)
    }
    
    @IBAction func doneAction() {
        delegate?.didFinishEditingImage(item.image, at: item.indexPath)
        dismiss(animated: true)
    }
    
    private func updateImage(with outputImage: CIImage) {
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)!
        item.image = UIImage.init(cgImage: imageRef, scale: item.image.scale, orientation: item.image.imageOrientation)
        imageView.image = item.image
    }
    
    private func updateInputImage(for filter: CIFilter) {
        let ciImage = CIImage(cgImage: item.image.cgImage!)
        filter.setValue(ciImage, forKey: "inputImage")
    }
    
}
