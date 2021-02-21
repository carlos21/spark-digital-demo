//
//  UIView+Animations.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

extension UIView {
    
    func addSubviewAnimated(_ view: UIView, duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: [.transitionCrossDissolve],
            animations: { [weak self] in
                self?.addSubview(view)
            },
            completion: { _ in
                completion?()
            })
    }
    
    func removeFromSuperViewAnimated(duration: TimeInterval) {
        guard let superview = self.superview else { return }
        
        UIView.transition(
            with: superview,
            duration: duration,
            options: [.transitionCrossDissolve],
            animations: { [weak self] in
                self?.removeFromSuperview()
        }, completion: nil)
    }
}
