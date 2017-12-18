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
    var isEditCellsEnabled: Bool! {
        didSet {
            updateLongPressGestureMinimumDuration()
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        updateLongPressGestureMinimumDuration()
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
        cell.editAction = !isEditCellsEnabled ? nil : {
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
    
    func updateLongPressGestureMinimumDuration() {
        // If the edit button is showing on the cells, then the long press needs
        // to be longer to avoid stealing the touch event. Otherwise, we want the
        // long press to be as quick as possible so it's easy to drag and move
        // cells.
        if let isEditCellsEnabled = isEditCellsEnabled, isEditCellsEnabled {
            longPressGesture.minimumPressDuration = 0.15
        } else {
            longPressGesture.minimumPressDuration = 0.05
        }
    }
    
    var sourceIndexPath: IndexPath?
    var movingView: UIView!
    var grabPoint: CGPoint!
    var possibleDestinationIndexPath: IndexPath?
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard isEditing else {
                return
            }
            let gestureLocation = gesture.location(in: collectionView)
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gestureLocation) else {
                return
            }
            sourceIndexPath = selectedIndexPath
            let sourceCell = collectionView.cellForItem(at: sourceIndexPath!) as! CollectionViewCell
            sourceCell.alpha = 0.5
            grabPoint = collectionView.convert(gestureLocation, to: sourceCell)
            let movingViewOrigin = CGPoint(x: gestureLocation.x - grabPoint.x, y: gestureLocation.y - grabPoint.y)
            movingView = UIView(frame: CGRect(origin: movingViewOrigin, size: sourceCell.bounds.size))
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: movingView.bounds.size))
            imageView.contentMode = .scaleAspectFill
            imageView.image = sourceCell.model.image
            movingView.clipsToBounds = true
            movingView.addSubview(imageView)
            collectionView.addSubview(movingView)
            collectionView.bringSubview(toFront: movingView)
        case .changed:
            let gestureLocation = gesture.location(in: collectionView)
            let movingViewOrigin = CGPoint(x: gestureLocation.x - grabPoint.x, y: gestureLocation.y - grabPoint.y)
            movingView.frame.origin = movingViewOrigin
            guard let newPossibleDestIP = collectionView.indexPathForItem(at: gestureLocation) else {
                if let previous = possibleDestinationIndexPath {
                    let previousCell = collectionView.cellForItem(at: previous) as! CollectionViewCell
                    previousCell.alpha = 1.0
                }
                return
            }
            guard let sourceIndexPath = sourceIndexPath, newPossibleDestIP.row != sourceIndexPath.row else {
                if let previous = possibleDestinationIndexPath {
                    let previousCell = collectionView.cellForItem(at: previous) as! CollectionViewCell
                    previousCell.alpha = 1.0
                }
                return
            }
            if let previous = possibleDestinationIndexPath {
                if previous.row == newPossibleDestIP.row {
                    return
                }
                let previousCell = collectionView.cellForItem(at: previous) as! CollectionViewCell
                previousCell.alpha = 1.0
            }
            possibleDestinationIndexPath = newPossibleDestIP
            let possibleDestCell = collectionView.cellForItem(at: possibleDestinationIndexPath!) as! CollectionViewCell
            possibleDestCell.alpha = 0.5
        case .ended:
            fallthrough
        default:
            guard let sourceIndexPath = sourceIndexPath else {
                return
            }
            guard let destinationIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                let sourceCell = collectionView.cellForItem(at: sourceIndexPath) as! CollectionViewCell
                sourceCell.alpha = 1.0
                movingView.removeFromSuperview()
                movingView = nil
                return
            }
            let possibleDestCell = collectionView.cellForItem(at: destinationIndexPath) as! CollectionViewCell
            possibleDestCell.alpha = 1.0
            let sourceCell = collectionView.cellForItem(at: sourceIndexPath) as! CollectionViewCell
            sourceCell.alpha = 1.0
            movingView.removeFromSuperview()
            movingView = nil
            
            let itemToMove = data.remove(at: sourceIndexPath.row)
            let destItem = data.remove(at: destinationIndexPath.row)
            data.insert(itemToMove, at: destinationIndexPath.row)
            data.insert(destItem, at: sourceIndexPath.row)
            
            collectionView.performBatchUpdates({
                collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                collectionView.moveItem(at: destinationIndexPath, to: sourceIndexPath)
            })
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize.width, height: cellSize.height)
    }

}
