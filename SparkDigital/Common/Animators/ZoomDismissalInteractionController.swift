//
//  ZoomDismissalInteractionController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

/// This objecf contains the logic for the animation between the PhotosViewController and the PhotoPageContainerViewController
class ZoomDismissalInteractionController: NSObject {
    
    // MARK: - Properties
    
    var transitionContext: UIViewControllerContextTransitioning?
    var animator: UIViewControllerAnimatedTransitioning?
    var fromReferenceImageViewFrame: CGRect?
    var toReferenceImageViewFrame: CGRect?
    
    // MARK: - Functions
    
    /// Contains the logic animation when swiping down in order to dismiss the photo detail
    /// - Parameters
    ///     - gestureRecognizer: object with information about the performed gesture
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let transitionContext = self.transitionContext,
            let animator = self.animator as? ZoomAnimator,
            let transitionImageView = animator.transitionImageView,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator),
            let toReferenceImageView = animator.toDelegate?.referenceImageView(for: animator),
            let fromReferenceImageViewFrame = self.fromReferenceImageViewFrame,
            let toReferenceImageViewFrame = self.toReferenceImageViewFrame else {
                return
        }
        
        fromReferenceImageView.isHidden = true
        
        let anchorPoint = CGPoint(x: fromReferenceImageViewFrame.midX, y: fromReferenceImageViewFrame.midY)
        let translatedPoint = gestureRecognizer.translation(in: fromReferenceImageView)
        let verticalDelta: CGFloat = translatedPoint.y < 0 ? 0 : translatedPoint.y

        let backgroundAlpha = backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
        let scale = scaleFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
        
        fromVC.view.alpha = backgroundAlpha
        
        transitionImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x,
                                y: anchorPoint.y + translatedPoint.y - transitionImageView.frame.height * (1 - scale) / 2.0)
        transitionImageView.center = newCenter
        
        toReferenceImageView.isHidden = true
        transitionContext.updateInteractiveTransition(1 - scale)
        toVC.tabBarController?.tabBar.alpha = 1 - backgroundAlpha
        
        if gestureRecognizer.state == .ended {
            
            let velocity = gestureRecognizer.velocity(in: fromVC.view)
            if velocity.y < 0 || newCenter.y < anchorPoint.y {
                
                //cancel
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        transitionImageView.frame = fromReferenceImageViewFrame
                        fromVC.view.alpha = 1.0
                        toVC.tabBarController?.tabBar.alpha = 0
                }, completion: { completed in
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        transitionImageView.removeFromSuperview()
                        animator.transitionImageView = nil
                        transitionContext.cancelInteractiveTransition()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        animator.toDelegate?.transitionDidEndWith(zoomAnimator: animator)
                        animator.fromDelegate?.transitionDidEndWith(zoomAnimator: animator)
                        self.transitionContext = nil
                })
                return
            }
            
            //start animation
            let finalTransitionSize = toReferenceImageViewFrame
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [],
                           animations: {
                            fromVC.view.alpha = 0
                            transitionImageView.frame = finalTransitionSize
                            toVC.tabBarController?.tabBar.alpha = 1
            }, completion: { completed in
                transitionImageView.removeFromSuperview()
                toReferenceImageView.isHidden = false
                fromReferenceImageView.isHidden = false
                
                self.transitionContext?.finishInteractiveTransition()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                animator.toDelegate?.transitionDidEndWith(zoomAnimator: animator)
                animator.fromDelegate?.transitionDidEndWith(zoomAnimator: animator)
                self.transitionContext = nil
            })
        }
    }
    
    /// Calculates the alpha according to how far the photo detail is from the center
    /// - Parameters
    ///     - view: instance of the view where the alpha will be applied
    func backgroundAlphaFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha:CGFloat = 1.0
        let finalAlpha: CGFloat = 0.0
        let totalAvailableAlpha = startingAlpha - finalAlpha
        let maximumDelta = view.bounds.height / 4.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha)
    }
    
    /// Calculates the scale according to how much the view moved from the original position
    /// - Parameters
    ///     - view: instance of the view to be scaled
    ///     - verticalDelta: distance that the object has moved from the original position
    func scaleFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingScale:CGFloat = 1.0
        let finalScale: CGFloat = 0.5
        let totalAvailableScale = startingScale - finalScale
        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        return startingScale - (deltaAsPercentageOfMaximun * totalAvailableScale)
    }
}

extension ZoomDismissalInteractionController: UIViewControllerInteractiveTransitioning {
    
    /// Called when the system needs to set up the interactive portions of a view controller transition and start the animations.
    /// - Parameters
    ///     - transitionContext: The context object containing information about the transition.
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        guard let animator = self.animator as? ZoomAnimator,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageViewFrame = animator.fromDelegate?.referenceImageViewFrameInTransitioningView(for: animator),
            let toReferenceImageViewFrame = animator.toDelegate?.referenceImageViewFrameInTransitioningView(for: animator),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator)
            else {
                return
        }
        
        animator.fromDelegate?.transitionWillStartWith(zoomAnimator: animator)
        animator.toDelegate?.transitionWillStartWith(zoomAnimator: animator)
        
        self.fromReferenceImageViewFrame = fromReferenceImageViewFrame
        self.toReferenceImageViewFrame = toReferenceImageViewFrame
        
        let referenceImage = fromReferenceImageView.image
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        if animator.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            animator.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
    }
}
