//
//  PhotosViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import PresentationLogic
import UIKit
import Rswift
import Core

final class PhotosViewController: UIViewController, IndicatableController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: FlexibleCollectionView!
    
    // MARK: - Properties
    
    var selectedIndexPath: IndexPath!
    
    lazy var viewModel: PhotosViewModel = {
        let transferService = AppContainer.shared.dataTransferService
        let getPhotosUseCase = GetPhotosUseCase(transferService: transferService)
        let downloadImageUseCase = DownloadImageUseCase(transferService: transferService)
        return PhotosViewModel(getListUseCase: getPhotosUseCase, downloadImageUseCase: downloadImageUseCase)
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.darkGray,
        ]
        var refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        setupUI()
        setupBindings()
        viewModel.loadData(type: .firstTimeLoad)
    }
    
    override func viewWillLayoutSubviews() {
        updateColumns()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.settings.insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        collectionView.settings.itemSpacing = 4
        updateColumns()
        collectionView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        viewModel.state.delegate(to: self) { (self, state) in
            self.showIndicator(visible: .hide, type: .fullScreen)
            
            switch state {
            case .idle:
                break
                
            case .loading:
                break
                
            case .success:
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                
            case .error(let message):
                let settings = IndicatorView.Settings(title: "",
                                                      message: message,
                                                      image: nil,
                                                      buttonTitle: R.string.localizable.retry()) { [weak self] in
                    self?.viewModel.loadData(type: .pullToRefresh)
                }
                self.refreshControl.endRefreshing()
                self.showIndicator(visible: .show(settings), type: .fullScreen)
            }
        }
        
        viewModel.photoUpdated.delegate(to: self) { (self, data) in
            guard let cell = self.collectionView.cellForItem(at: data.indexPath) as? PhotoCell else { return }
            cell.setup(photo: data.photo)
        }
    }
    
    private func updateColumns() {
        if UIDevice.current.orientation.isLandscape {
            collectionView.settings.numberOfColumns = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 6
        } else {
            collectionView.settings.numberOfColumns = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
        }
    }
    
    @objc private func didPullToRefresh() {
        viewModel.loadData(type: .pullToRefresh)
    }
}

extension PhotosViewController: FlexibleCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCell.identifier,
                                                      for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.row]
        guard let photoCell = cell as? PhotoCell else { return }
        photoCell.setup(photo: photo)
        viewModel.download(photo: photo, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemWithWidth width: CGFloat,
                        atIndexPath indexPath: IndexPath) -> CGFloat {
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        
        let photoPageController = PhotoPageContainerViewController.instance()
        navigationController?.delegate = photoPageController.transitionController
        
        photoPageController.transitionController.fromDelegate = self
        photoPageController.transitionController.toDelegate = photoPageController
        photoPageController.delegate = self
        photoPageController.currentIndex = self.selectedIndexPath.row
        photoPageController.photos = viewModel.photos
        navigationController?.pushViewController(photoPageController, animated: true)
    }
}

extension PhotosViewController: PhotoPageContainerViewControllerDelegate {
 
    func containerViewController(_ containerViewController: PhotoPageContainerViewController,
                                 indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension PhotosViewController: ZoomAnimatorDelegate {
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
           
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
            
        } else {
            //Guard against nil return values
            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as! PhotoCell
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let selectedIndexPath = self.selectedIndexPath else { return nil }
        
        // Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        return referenceImageView
    }
    
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
