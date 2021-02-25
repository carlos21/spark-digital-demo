//
//  PhotosPageContainerViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

protocol PhotoPageContainerViewControllerDelegate: class {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

/// Acts as the container for each photo detail
/// - Allows the user to swipe horizontally and navigate through the photos more easily
final class PhotoPageContainerViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: PhotoDetailViewController {
        return self.pageViewController.viewControllers![0] as! PhotoDetailViewController
    }
    
    var photos: [PhotoItemViewModel]!
    var currentIndex = 0
    var nextIndex: Int?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var transitionController = ZoomTransitionController()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// Sets up the UI when the users enters the screen
    /// Creates the UIPageViewController and the first PhotoDetailViewController
    /// Creates the gesture to dismiss this screen
    private func setupUI() {
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
        
        let detailController = PhotoDetailViewController.instance(photo: photos[currentIndex].photo)
        detailController.index = currentIndex
        
        let viewControllers = [detailController]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    /// This function is called when it detects a pan gesture
    /// Tells the transition controller to start animating the photo when closing
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.transitionController.isInteractive = true
            let _ = self.navigationController?.popViewController(animated: true)
            
        case .ended:
            if self.transitionController.isInteractive {
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
            
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
}

extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    /// Returns the view controller before the given view controller.
    /// - Parameters
    ///     - pageViewController: page controller instance
    ///     - viewController: current PhotoDetailViewController instance
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        
        let photoDetailController = PhotoDetailViewController.instance(photo: photos[currentIndex - 1].photo)
        photoDetailController.index = currentIndex - 1
        return photoDetailController
    }
    
    /// Returns the view controller after the given view controller.
    /// - Parameters
    ///     - pageViewController: page controller instance
    ///     - viewController: current PhotoDetailViewController instance
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == (self.photos.count - 1) {
            return nil
        }
        
        let photoDetailController = PhotoDetailViewController.instance(photo: photos[currentIndex + 1].photo)
        photoDetailController.index = currentIndex + 1
        return photoDetailController
    }
    
    /// Called before a gesture-driven transition begins.
    /// - Parameters
    ///     - pageViewController: page controller instance
    ///     - pendingViewControllers: The view controllers that are being transitioned to.
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let nextVC = pendingViewControllers.first as? PhotoDetailViewController else { return }
        self.nextIndex = nextVC.index
    }
    
    /// Called before a gesture-driven transition begins.
    /// - Parameters
    ///     - pageViewController: page controller instance
    ///     - finished: true if the animation finished; otherwise, false.
    ///     - previousViewControllers: The view controllers prior to the transition.
    ///     - completed: true if the user completed the page-turn gesture; otherwise, false
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed && self.nextIndex != nil {
            self.currentIndex = self.nextIndex!
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
}

extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
    
    /// Returns an image view used when zooming in o zooming out
    /// - Parameters
    ///     - zoomAnimator: instance of the object that contains the logic to perform the animation
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.currentViewController.imageView
    }
    
    /// Returns an CGRect used when zooming in o zooming out
    /// - Parameters
    ///     - zoomAnimator: instance of the object that contains the logic to perform the animation
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.currentViewController.imageView.frame
    }
}

extension PhotoPageContainerViewController: InstantiableController {
    
    /// Creates an instance using the storyboard
    static func instance() -> PhotoPageContainerViewController {
        return R.storyboard.photosPageContainer.instantiateInitialViewController()!
    }
}
