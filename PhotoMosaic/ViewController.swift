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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, CollectionViewControllerDelegate, EditImageViewControllerDelegate {
    
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
        updateIsEditCellsEnabled(true)
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
        // Hide the edit buttons on the cells and reset the canvas to its actual
        // size before getting the image.
        let isEditCellsEnabled = collectionViewController.isEditCellsEnabled ?? false
        updateIsEditCellsEnabled(false)
        let zoomScale = scrollView.zoomScale
        let contentOffset = scrollView.contentOffset
        resetCanvasZoomAction()
        
        let image = UIImage(view: collectionViewController.collectionView)
        print("image to share: \(image)")
        
        // Restore the edit buttons and canvas size (as needed).
        updateIsEditCellsEnabled(isEditCellsEnabled)
        scrollView.zoomScale = zoomScale
        scrollView.contentOffset = contentOffset
        
        // Display the activity VC so the user can share / save the image.
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
    
    @IBAction func resetCanvasZoomAction() {
        let currentMinZoomScale = scrollView.minimumZoomScale
        let currentMaxZoomScale = scrollView.maximumZoomScale
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = currentMinZoomScale
        scrollView.maximumZoomScale = currentMaxZoomScale
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
    
    @IBAction func editCellsSwichAction(_ sender: UISwitch) {
        updateIsEditCellsEnabled(sender.isOn)
    }
    
    func updateIsEditCellsEnabled(_ enabled: Bool) {
        collectionViewController.isEditCellsEnabled = enabled
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    @IBAction func updateCanvasSizeAction() {
        let ppi = CGFloat(UIScreen.pointsPerInch!)
        
        containerViewWidth.constant = CGFloat.from(widthTextField.text) * ppi
        containerViewHeight.constant = CGFloat.from(heightTextField.text) * ppi
        
        let cellSize = CGFloat.from(cellSizeTextField.text) * ppi
        collectionViewController.cellSize = CGSize(width: cellSize, height: cellSize)
        
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        cellSizeTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionVC = segue.destination as? CollectionViewController {
            collectionViewController = collectionVC
            collectionViewController.delegate = self
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info for selected media:\n\(info)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            collectionViewController.addData(for: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true)
        collectionViewController.collectionView.reloadData()
    }
    
    func didSelectImage(_ image: UIImage, at indexPath: IndexPath) {
        let editImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditImageViewController") as! EditImageViewController
        editImageVC.item = (image: image, indexPath: indexPath)
        editImageVC.delegate = self
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .coverVertical
        present(editImageVC, animated: true)
    }
    
    func didFinishEditingImage(_ image: UIImage, at indexPath: IndexPath) {
        collectionViewController.updateData(at: indexPath, with: image)
        collectionViewController.collectionView.reloadData()
    }
    
}

