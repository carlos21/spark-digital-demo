//
//  ZoomTransitionController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

class ZoomTransitionController: NSObject {
    
    // MARK: - Properties
    
    let animator: ZoomAnimator
    let interactionController: ZoomDismissalInteractionController
    var isInteractive: Bool = false

    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    // MARK: - Functions
    
    override init() {
        animator = ZoomAnimator()
        interactionController = ZoomDismissalInteractionController()
        super.init()
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        self.interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
    }
}

/// These methods are only called when presenting a view controller (not when using UINavigationController)
extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
    
    /// Returns an animator object that contains the logic for the animation
    /// Called when presenting a view controller present(_:animated:completion:)
    /// - Parameters:
    ///     - presented: The view controller object that is about to be presented onscreen.
    ///     - presenting: The view controller that is presenting the view controller in the presented parameter.
    ///     - source: The view controller whose present(_:animated:completion:) method was called.
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = true
        self.animator.fromDelegate = fromDelegate
        self.animator.toDelegate = toDelegate
        return self.animator
    }
    
    /// Returns an animator object that contains the logic for the animation
    /// Called when dismissing a view controller
    /// - Parameters:
    ///     - dismissed: The view controller object that is about to be dismissed.
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = false
        let tmp = self.fromDelegate
        self.animator.fromDelegate = self.toDelegate
        self.animator.toDelegate = tmp
        return self.animator
    }

    /// Returns an interaction object for when dismissing a controller
    ///     - animator: The transition animator object returned by your animationController(forDismissed:) method.
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.isInteractive {
            return nil
        }
        
        self.interactionController.animator = animator
        return self.interactionController
    }
}

extension ZoomTransitionController: UINavigationControllerDelegate {
    
    /// Returns an animator object that contains the logic for the animation
    /// Called when pussing or popping a controller from a UINavigationController
    /// - Parameters:
    ///     - navigationController: The navigation controller whose navigation stack is changing.
    ///     - operation: push or pop
    ///     - fromVC: The currently visible view controller.
    ///     - toVC: The view controller that should be visible at the end of the transition.
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            self.animator.isPresenting = true
            self.animator.fromDelegate = fromDelegate
            self.animator.toDelegate = toDelegate
        } else {
            self.animator.isPresenting = false
            let tmp = self.fromDelegate
            self.animator.fromDelegate = self.toDelegate
            self.animator.toDelegate = tmp
        }
        
        return self.animator
    }
    
    /// Returns an animator object that contains the logic for the animation
    /// Called when pussing or popping a controller from a UINavigationController
    /// - Parameters:
    ///     - navigationController: The navigation controller whose navigation stack is changing.
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.isInteractive {
            return nil
        }
        
        self.interactionController.animator = animator
        return self.interactionController
    }
}
