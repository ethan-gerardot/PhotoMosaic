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
        
        let ciImage = CIImage(cgImage: item.image.cgImage!)
        context = CIContext(options: nil)
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(ciImage, forKey: "inputImage")
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(ciImage, forKey: "inputImage")
    }
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness")
        updateImage(with: brightnessFilter.outputImage!)
    }
    
    @IBAction func contrastSliderValueChanged(_ sender: UISlider) {
        contrastFilter.setValue(NSNumber(value: sender.value), forKey: "inputContrast")
        updateImage(with: contrastFilter.outputImage!)
    }
    
    @IBAction func cancelAction() {
        dismiss(animated: true)
    }
    
    @IBAction func doneAction() {
        delegate?.didFinishEditingImage(item.image, at: item.indexPath)
        dismiss(animated: true)
    }
    
    private func updateImage(with outputImage: CIImage) {
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        item.image = UIImage(cgImage: imageRef!)
        imageView.image = item.image
    }
    
}
