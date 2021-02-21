//
//  PhotoZoomViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import PresentationLogic
import Core

protocol PhotoZoomViewControllerDelegate: class {
    
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

final class PhotoZoomViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    weak var delegate: PhotoZoomViewControllerDelegate?
    var index: Int = 0
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    var image: UIImage? {
        guard let data = viewModel.photo?.bigImageState.data else { return nil }
        return UIImage(data: data)
    }
    
    lazy var viewModel: PhotoZoomViewModel = {
        let transferService = AppContainer.shared.dataTransferService
        let downloadImageUseCase = DownloadImageUseCase(transferService: transferService)
        return PhotoZoomViewModel(downloadImageUseCase: downloadImageUseCase)
    }()
    
    // MARK: - Functions
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.download()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
    }
    
    private func setupUI() {
        self.scrollView.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.imageView.image = self.image
        self.imageView.frame = CGRect(x: self.imageView.frame.origin.x,
                                      y: self.imageView.frame.origin.y,
                                      width: self.image?.size.width ?? 0,
                                      height: self.image?.size.height ?? 0)
        self.view.addGestureRecognizer(self.doubleTapGestureRecognizer)
    }
    
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
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: self.imageView)
        var newZoomScale = self.scrollView.maximumZoomScale
        
        if self.scrollView.zoomScale >= newZoomScale || abs(self.scrollView.zoomScale - newZoomScale) <= 0.01 {
            newZoomScale = self.scrollView.minimumZoomScale
        }
        
        let width = self.scrollView.bounds.width / newZoomScale
        let height = self.scrollView.bounds.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        self.scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    fileprivate func updateZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        let contentHeight = yOffset * 2 + self.imageView.frame.height
        view.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: contentHeight)
    }
}

extension PhotoZoomViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(self.view.bounds.size)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.photoZoomViewController(self, scrollViewDidScroll: scrollView)
    }
}

extension PhotoZoomViewController: InstantiableController {
    
    static func instance() -> PhotoZoomViewController {
        return R.storyboard.photoZoom.instantiateInitialViewController()!
    }
    
    static func instance(photo: PhotoVM) -> PhotoZoomViewController {
        let controller = R.storyboard.photoZoom.instantiateInitialViewController()!
        controller.viewModel.photo = photo
        return controller
    }
}
