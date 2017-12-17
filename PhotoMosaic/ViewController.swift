//
//  ViewController.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/16/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit
import Photos
import UIScreenExtension

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var cellSizeTextField: UITextField!
    
    weak var collectionViewController: CollectionViewController!
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        updateIsScaleCanvasEnabled(true)
        updateIsMoveCellsEnabled(true)
        updateIsScaleCellsEnabled(true)
        updateCanvasSizeAction()
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({
                if $0 == .authorized {
                    self.setupPicker()
                }
            })
        } else {
            setupPicker()
        }
    }
    
    func setupPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary), let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
            print("media types: \(mediaTypes)")
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = [mediaTypes.first!]
            imagePickerController.delegate = self
        }
    }

    @IBAction func insertAction() {
        modalPresentationStyle = .popover
        present(imagePickerController, animated: true)
        collectionViewController.data = []
    }

    @IBAction func shareAction() {
        resetCanvasZoomAction()
        let image = UIImage(view: collectionViewController.collectionView)
        print(image)
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        modalPresentationStyle = .popover
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = shareButton
        }
        present(activityViewController, animated: true)
    }
    
    @IBAction func scaleCanvasSwitchAction(_ sender: UISwitch) {
        updateIsScaleCanvasEnabled(sender.isOn)
    }
    
    func updateIsScaleCanvasEnabled(_ enabled: Bool) {
        scrollView.isScrollEnabled = enabled
        scrollView.minimumZoomScale = enabled ? 0.1 : scrollView.zoomScale
        scrollView.maximumZoomScale = enabled ? 10.0 : scrollView.zoomScale
    }
    
    @IBAction func moveCellsSwitchAction(_ sender: UISwitch) {
        updateIsMoveCellsEnabled(sender.isOn)
    }
    
    func updateIsMoveCellsEnabled(_ enabled: Bool) {
        collectionViewController.setEditing(enabled, animated: true)
    }
    
    @IBAction func scaleCellsSwichAction(_ sender: UISwitch) {
        updateIsScaleCellsEnabled(sender.isOn)
    }
    
    func updateIsScaleCellsEnabled(_ enabled: Bool) {
        collectionViewController.isScaleCellsEnabled = enabled
    }
    
    @IBAction func resetCanvasZoomAction() {
        let currentMinZoomScale = scrollView.minimumZoomScale
        let currentMaxZoomScale = scrollView.maximumZoomScale
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = currentMinZoomScale
        scrollView.maximumZoomScale = currentMaxZoomScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    @IBAction func updateCanvasSizeAction() {
        let ppi = CGFloat(UIScreen.pointsPerInch!)
        print(ppi)
        
        containerViewWidth.constant = CGFloat.from(widthTextField.text) * ppi
        containerViewHeight.constant = CGFloat.from(heightTextField.text) * ppi
        
        let cellSize = CGFloat.from(cellSizeTextField.text) * ppi
        collectionViewController.cellSize = CGSize(width: cellSize, height: cellSize)
        
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        cellSizeTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cvc = segue.destination as? CollectionViewController {
            collectionViewController = cvc
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info: \(info)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            collectionViewController.data.append(CellModel(image: image))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true)
        collectionViewController.collectionView.reloadData()
    }
    
}

