//
//  PhotoViewController+Layout.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 24/02/21.
//

import Foundation
import UIKit

/// This extension contains the delegate methods to make the UICollectionView work
extension PhotosViewController: FlexibleCollectionViewLayoutDelegate {
    
    /// Instantiates the Page container to show the photo detail
    /// Sets the transitionController as delegate of the UINavigationController to control the animation when transitioning
    private func showPhotosPageContainer() {
        let photoPageController = PhotoPageContainerViewController.instance()
        navigationController?.delegate = photoPageController.transitionController
        
        photoPageController.transitionController.fromDelegate = self
        photoPageController.transitionController.toDelegate = photoPageController
        photoPageController.delegate = self
        photoPageController.currentIndex = self.selectedIndexPath.row
        photoPageController.photos = viewModel.photos
        navigationController?.pushViewController(photoPageController, animated: true)
    }
    
    /// Specified the number of items for the unique section
    /// - Parameters:
    ///     - collectionView: instance of the collection view
    ///     - numberOfItemsInSection: number of items, in this cases number of photos
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.photos.count
    }
    
    /// Creates or reuses a cell to display each photo
    /// - Parameters:
    ///     - collectionView: instance of the collection view
    ///     - indexPath: position of the cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoViewModel = viewModel.photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoViewModel.reuseIdentifier,
                                                      for: indexPath)
        return cell
    }
    
    /// This method is called right before presenting a cell
    /// - Parameters:
    ///     - collectionView: instance of the collection view
    ///     - cell:cell for a photo
    ///     - indexPath: position of the cell
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let photoViewModel = viewModel.photos[indexPath.row]
        guard let photoCell = cell as? PhotoCell else { return }
        photoViewModel.setup(photoCell)
        viewModel.download(photo: photoViewModel.photo, indexPath: indexPath)
    }
    
    /// Returns the height for the cell. Since we want to show a square, we return the width
    /// - Parameters:
    ///     - collectionView: instance of the collection view
    ///     - width: width of the cell
    ///     - indexPath: position of the cell
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemWithWidth width: CGFloat,
                        atIndexPath indexPath: IndexPath) -> CGFloat {
        return width
    }
    
    /// Returns the height for the cell. Since we want to show a square, we return the width
    /// - Parameters:
    ///     - collectionView: instance of the collection view
    ///     - indexPath: position of the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewModel = viewModel.photos[indexPath.row]
        
        guard photoViewModel.photo.thumbnailData != nil else { return }
        self.selectedIndexPath = indexPath
        showPhotosPageContainer()
    }
}
