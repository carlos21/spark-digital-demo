//
//  ZoomAnimator.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

protocol ZoomAnimatorDelegate: class {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator)
    func transitionDidEndWith(zoomAnimator: ZoomAnimator)
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView?
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect?
}

extension ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
}

/// This object contains the main logic for the zoom in/out animation
class ZoomAnimator: NSObject {
    
    // MARK: - Properties
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?

    var transitionImageView: UIImageView?
    var isPresenting: Bool = true
    
    // MARK: - Functions
    
    /// This method is called to start animating a photo when going to the photo detail
    /// Uses the fromDelegate and toDelegate objects to extract information from the view controllers involved in the transition
    /// - Parameters:
    ///     - transitionContext: object with information about the elements involved in the ttransition
    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self)
        else {
            return
        }
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toVC.view.alpha = 0
        toReferenceImageView.isHidden = true
        containerView.addSubview(toVC.view)
        
        let referenceImage = fromReferenceImageView.image!
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage, forView: toVC.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [UIView.AnimationOptions.transitionCrossDissolve],
            animations: {
                self.transitionImageView?.frame = finalTransitionSize
                toVC.view.alpha = 1.0
                fromVC.tabBarController?.tabBar.alpha = 0
        }, completion: { completed in
            self.transitionImageView?.removeFromSuperview()
            toReferenceImageView.isHidden = false
            fromReferenceImageView.isHidden = false
            
            self.transitionImageView = nil
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        })
    }
    
    /// This method is called to start animating a photo when going from the photo detail to the list
    /// Uses the fromDelegate and toDelegate objects to extract information from the view controllers involved in the transition
    /// - Parameters:
    ///     - transitionContext: object with information about the elements involved in the ttransition
    fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
            let toReferenceImageViewFrame = self.toDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {
                return
        }
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toReferenceImageView.isHidden = true
        
        let referenceImage = fromReferenceImageView.image!
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = toReferenceImageViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {
                        fromVC.view.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
                        toVC.tabBarController?.tabBar.alpha = 1
        }, completion: { completed in
            self.transitionImageView?.removeFromSuperview()
            toReferenceImageView.isHidden = false
            fromReferenceImageView.isHidden = false
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        })
    }
    
    /// Calculates the final CGRect when zooming in
    /// - Parameters:
    ///     - image: image used for the animation
    ///     - view: parent view
    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    
    /// Asks your animator object for the duration (in seconds) of the transition animation.
    /// - Parameters:
    ///     - transitionContext: object with information about the elements involved in the ttransition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.isPresenting ? 0.5 : 0.25
    }
    
    /// Tells your animator object to perform the transition animations.
    /// - Parameters:
    ///     - transitionContext: object with information about the elements involved in the ttransition
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
