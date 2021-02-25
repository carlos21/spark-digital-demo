//
//  PhotosViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Rswift
import Core

/// Displays a list of photos.
///     - It first shows a spinning wheel when retrieving the list of photos
///     - If there is an error, it lets you try again
///     - The number of photos displayed depends on the device and orientation
///     - It only loads the thumbnal photos as the user scroll down to improve performance
///     - It shows a nice animation when opening a photo detail or when closing it
final class PhotosViewController: UIViewController, IndicatableController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: FlexibleCollectionView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // MARK: - Properties
    
    var selectedIndexPath: IndexPath!
    
    lazy var viewModel: PhotosViewModel = {
        let transferService = AppContainer.shared.dataTransferService
        let photosRepository = PhotosRepository(transferService: transferService)
        return PhotosViewModel(photosRepository: photosRepository)
    }()
    
    /// This view is visible when pulling the list to refresh
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
    
    /// Sets up the UI
    /// Starts listining to events
    /// Starts calling the web service to get the photos
    override func viewDidLoad() {
        setupUI()
        setupBindings()
        viewModel.loadData(type: .firstTimeLoad)
    }
    
    /// Invalidates the layout to reorganize the elements
    /// Calculates the number of columns again
    override func viewWillLayoutSubviews() {
        updateColumns()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    /// Sets up the UI when the users enters the screen
    ///     - Defines a style for the spinning wheel
    ///     - Defines the style for the collection view
    private func setupUI() {
        activityIndicatorView.type = .circleStrokeSpin
        activityIndicatorView.color = .darkGray
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.settings.insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        collectionView.settings.itemSpacing = 4
        updateColumns()
        collectionView.refreshControl = refreshControl
    }
    
    /// Starts listining to events
    ///     - showListLoading: shows the spinning wheel while loading
    ///     - showListSuccess: reload the collection view
    ///     - showListError: shows an error in the middle of the screen with a button to try again
    ///     - photoUpdated: reloads a photo when the thumbnail downloaded
    private func setupBindings() {
        viewModel.showListLoading.delegate(to: self) { (self, _) in
            self.activityIndicatorView.startAnimating()
        }
        
        viewModel.showListSuccess.delegate(to: self) { (self, _) in
            self.activityIndicatorView.stopAnimating()
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
        }
        
        viewModel.showListError.delegate(to: self) { (self, message) in
            let settings = IndicatorView.Settings(title: "",
                                                  message: message,
                                                  image: nil,
                                                  buttonTitle: R.string.localizable.retry()) { [weak self] in
                self?.viewModel.loadData(type: .firstTimeLoad)
            }
            self.activityIndicatorView.stopAnimating()
            self.refreshControl.endRefreshing()
            self.showIndicator(visible: .show(settings), type: .fullScreen)
        }
        
        viewModel.photoUpdated.delegate(to: self) { (self, data) in
            guard let cell = self.collectionView.cellForItem(at: data.indexPath) as? PhotoCell else { return }
            let photoViewModel = self.viewModel.photos[data.indexPath.row]
            photoViewModel.setup(cell)
        }
    }
    
    /// Calculates the number of columns based on the device and orientation
    private func updateColumns() {
        if UIDevice.current.orientation.isLandscape {
            collectionView.settings.numberOfColumns = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 6
        } else {
            collectionView.settings.numberOfColumns = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
        }
    }
    
    /// Call the web server again to refresh the list of photos
    @objc private func didPullToRefresh() {
        viewModel.loadData(type: .pullToRefresh)
    }
}

extension PhotosViewController: InstantiableController {
    
    /// Creates an instance using the storyboard
    static func instance() -> PhotosViewController {
        return R.storyboard.photos.instantiateInitialViewController()!
    }
}

extension PhotosViewController: PhotoPageContainerViewControllerDelegate {
 
    /// When the user scrolls horizontally while being in the photo detail, this method is executed to automatically scroll to the corresponding thumbnail
    /// - Parameters
    ///     - containerViewController: instance of the container
    ///     - currentIndex: current index in the photo detail
    func containerViewController(_ containerViewController: PhotoPageContainerViewController,
                                 indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}
