//
//  PhotosViewController+Animation.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 24/02/21.
//

import Foundation
import UIKit

/// This extension contains the delegate implementation methods 
extension PhotosViewController: ZoomAnimatorDelegate {
    
    /// This function prevents the collectionView from accessing a deallocated cell. In the event
    /// that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    /// - Parameters:
    ///     - selectedIndexPath: holds the position of the selected cell
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        /// Get the array of visible cells in the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        /// If the current indexPath is not visible in the collectionView,
        /// scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
           
            /// Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            /// Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            /// Guard against nil values
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX,
                                                 y: UIScreen.main.bounds.midY,
                                                 width: 100.0,
                                                 height: 100.0))
            }
            /// The PhotoCell was found in the collectionView, return the image
            let photoViewModel = viewModel.photos[self.selectedIndexPath.row]
            let imageView = UIImageView(frame: guardedCell.imageView.frame)
            if let data = photoViewModel.photo.bigImageData {
                imageView.image = UIImage(data: data)
            }
            return imageView
            
        } else {
            /// Guard against nil return values
            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            
            /// The PhotoCell was found in the collectionView, return the image
            let photoViewModel = viewModel.photos[self.selectedIndexPath.row]
            let imageView = UIImageView(frame: guardedCell.imageView.frame)
            if let data = photoViewModel.photo.bigImageData {
                imageView.image = UIImage(data: data)
            }
            return imageView
        }
        
    }
    
    /// This function prevents the collectionView from accessing a deallocated cell. In the
    /// event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    /// - Parameters:
    ///     - selectedIndexPath: holds the position of the selected cell
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        /// Get the currently visible cells from the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        /// If the current indexPath is not visible in the collectionView,
        /// scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            /// Scroll the collectionView to the cell that is currently offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            /// Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            /// Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        
        /// Otherwise the cell should be visible
        else {
            /// Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            /// The cell was found successfully
            return guardedCell.frame
        }
    }
    
    /// This method is called once the animation ends after zooming in order zooming out
    /// - Parameters:
    ///     - zoomAnimator: animator object that contains the animation logic
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        guard let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell else { return }
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    /// Returns an image view to be animated during the transition
    /// - Parameters:
    ///     - zoomAnimator: animator object that contains the animation logic
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let selectedIndexPath = self.selectedIndexPath else { return nil }
        
        // Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        return referenceImageView
    }
    
    /// Returns an CGRect where it should start the transition
    /// - Parameters:
    ///     - zoomAnimator: animator object that contains the animation logic
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        self.view.layoutIfNeeded()
        self.collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        let cellFrame = self.collectionView.convert(unconvertedFrame, to: self.view)
        if cellFrame.minY < self.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX,
                          y: self.collectionView.contentInset.top,
                          width: cellFrame.width,
                          height: cellFrame.height - (self.collectionView.contentInset.top - cellFrame.minY))
        }
        return cellFrame
    }
}
