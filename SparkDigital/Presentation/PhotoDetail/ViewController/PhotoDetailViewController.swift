//
//  PhotoDetailViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import SnapKit
import Core

/// This screen shows the biggest version of the photo
/// - It's contained within a UIPageViewController
/// - It only downloads a photo when accessing to it. If it was already downloaded, it just shows it
final class PhotoDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    var index: Int = 0
    var topConstraint: Constraint!
    var bottomConstraint: Constraint!
    var rightConstraint: Constraint!
    var leftConstraint: Constraint!
    
    /// Holds the current select image
    var image: UIImage? {
        guard let data = viewModel.photo?.bigImageState.data else { return nil }
        return UIImage(data: data)
    }

    lazy var viewModel: PhotoDetailViewModel = {
        let transferService = AppContainer.shared.dataTransferService
        let photosRepository = PhotosRepository(transferService: transferService)
        return PhotoDetailViewModel(photosRepository: photosRepository)
    }()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.download()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePhotoConstraints()
    }
    
    /// Sets up the UI when the users enters the screen
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.image
        imageView.snp.makeConstraints {
            self.topConstraint = $0.top.equalTo(0).constraint
            self.bottomConstraint = $0.bottom.equalTo(0).constraint
            self.rightConstraint = $0.right.equalTo(0).constraint
            self.leftConstraint = $0.left.equalTo(0).constraint
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.width.equalTo(self.imageView.snp.height).multipliedBy(1.0).priority(750)
        }
    }
    
    /// Starts listening photo events
    private func setupBindings() {
        viewModel.photoUpdated.delegate(to: self) { (self, photo) in
            switch photo.bigImageState {
            case .loading:
                break
                
            case .success(let data):
                self.imageView.image = UIImage(data: data)
                
            default:
                if let data = photo.thumbnailData {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    /// Checks the device orientation to always show the photo as a square at the center
    /// If it's landscape, we keep the top and button constraints
    /// If it's portrait, we keep the right and left constraints
    private func updatePhotoConstraints() {
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.topConstraint.activate()
            self.bottomConstraint.activate()
            self.rightConstraint.deactivate()
            self.leftConstraint.deactivate()
        } else {
            self.topConstraint.deactivate()
            self.bottomConstraint.deactivate()
            self.rightConstraint.activate()
            self.leftConstraint.activate()
        }
    }
}

extension PhotoDetailViewController: InstantiableController {
    
    /// Creates an instance using the storyboard
    static func instance() -> PhotoDetailViewController {
        return R.storyboard.photoDetail.instantiateInitialViewController()!
    }
    
    /// Creates an instance using the storyboard
    /// - Parameters
    ///     - photo: photo object that contains the data and the states to control the download
    static func instance(photo: PhotoVM) -> PhotoDetailViewController {
        let controller = instance()
        controller.viewModel.photo = photo
        return controller
    }
}
