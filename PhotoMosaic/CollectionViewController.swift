//
//  CollectionViewController.swift
//  PhotoMosaic
//
//  Created by Ethan Gerardot on 12/16/17.
//  Copyright © 2017 Ethan Gerardot. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

protocol CollectionViewControllerDelegate: class {
    
    func didSelectImage(_ image: UIImage, at indexPath: IndexPath)
    
}

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: CollectionViewControllerDelegate?
    
    var data: [CellModel] = []
    var cellSize: CGSize = .zero {
        didSet {
            var newData: [CellModel] = []
            for item in data {
                let image = item.image
                newData.append(CellModel(image: image, cellSize: cellSize))
            }
            data = newData
            
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
    var isScaleCellsEnabled: Bool! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.05
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func addData(for image: UIImage) {
        data.append(CellModel(image: image, cellSize: cellSize))
    }
    
    func updateData(at indexPath: IndexPath, with image: UIImage) {
        data[indexPath.row] = CellModel(oldModel: data[indexPath.row], newImage: image)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.model = data[indexPath.row]
        cell.editAction = {
            let image = self.data[indexPath.row].image
            self.delegate?.didSelectImage(image, at: indexPath)
        }
        cell.isScaleEnabled = isScaleCellsEnabled
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        longPressGesture.isEnabled = editing
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = data.remove(at: sourceIndexPath.row)
        data.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard isEditing else {
                return
            }
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize.width, height: cellSize.height)
    }

}
