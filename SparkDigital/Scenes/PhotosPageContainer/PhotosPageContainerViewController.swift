//
//  PhotosPageContainerViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import PresentationLogic

protocol PhotoPageContainerViewControllerDelegate: class {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

final class PhotoPageContainerViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties
    
    var currentMode: ScreenMode = .normal
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: PhotoDetailViewController {
        return self.pageViewController.viewControllers![0] as! PhotoDetailViewController
    }
    
    var photos: [PhotoVM]!
    var currentIndex = 0
    var nextIndex: Int?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var transitionController = ZoomTransitionController()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.panGestureRecognizer.delegate = self
        self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
        
        let detailController = PhotoDetailViewController.instance(photo: photos[currentIndex])
        detailController.index = currentIndex
        
        let viewControllers = [detailController]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            var velocityCheck: Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            } else {
                velocityCheck = velocity.y < 0
            }
            
            if velocityCheck {
                return false
            }
        }
        return true
    }
    
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
    
    @objc func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if self.currentMode == .full {
            changeScreenMode(to: .normal)
            self.currentMode = .normal
        } else {
            changeScreenMode(to: .full)
            self.currentMode = .full
        }
    }
    
    func changeScreenMode(to: ScreenMode) {
        navigationController?.setNavigationBarHidden(to == .full, animated: false)
    }
}

extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        
        let photoDetailController = PhotoDetailViewController.instance(photo: photos[currentIndex - 1])
        photoDetailController.index = currentIndex - 1
        return photoDetailController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == (self.photos.count - 1) {
            return nil
        }
        
        let photoDetailController = PhotoDetailViewController.instance(photo: photos[currentIndex + 1])
        photoDetailController.index = currentIndex + 1
        return photoDetailController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let nextVC = pendingViewControllers.first as? PhotoDetailViewController else { return }
        self.nextIndex = nextVC.index
    }
    
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
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.currentViewController.imageView.frame
//        return self.currentViewController.scrollView.convert(self.currentViewController.imageView.frame,
//                                                             to: self.currentViewController.view)
    }
}

extension PhotoPageContainerViewController: InstantiableController {
    
    static func instance() -> PhotoPageContainerViewController {
        return R.storyboard.photosPageContainer.instantiateInitialViewController()!
    }
}

extension PhotoPageContainerViewController {
    
    enum ScreenMode {
        
        case full, normal
    }
}
