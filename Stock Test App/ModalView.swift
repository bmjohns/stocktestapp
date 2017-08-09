//
//  ModalView.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/6/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

/// Animation direction that the modal will and and disappear from
///
/// - noAnimation: Modal will just appear.
/// - bottom: Modal will animate from the bottom.
/// - right: Modal will animate from the right.
enum ModalAnimationDirection {
    case noAnimation
    case bottom
    case right
}


/// TNTModalView that will show/hide itself into parentview.
class ModalView: UIView {
    
    // MARK: Public Functions
    
    
    /// Will show or hide self based on current state.
    ///
    /// - Parameters:
    ///   - constraint: NSLayoutConstraint of the screen we want to show or hide.
    ///   - completionBlock: Completion block that will be enacted when UI update is complete.
    func updateHiddenScreen(withConstraint constraint: NSLayoutConstraint, completionBlock: (() -> ())?) {
        
        updateHiddenScreen(withConstraint: constraint,
                           animated: false,
                           animateFrom: .noAnimation,
                           completionBlock: completionBlock)
    }
    
    
    /// Will show or hide self based on current state, with an animation.
    ///
    /// - Parameters:
    ///   - constraint: NSLayoutConstraint of the edge of self that is closest to parent view when hidden.
    ///   - animationDirection: ModalAnimationDirection that the view should animate from.
    ///   - completionBlock: Completion block that will be enacted when UI update is complete.
    func updateHiddenScreen(withConstraint constraint: NSLayoutConstraint, animateFrom animationDirection: ModalAnimationDirection, completionBlock: (() -> ())?) {
        
        updateHiddenScreen(withConstraint: constraint,
                           animated: true,
                           animateFrom: animationDirection,
                           completionBlock: completionBlock)
    }
    
    // MARK: Private Functions
    
    /// Will show or hide self based on current state, with an animation.
    ///
    /// - Parameters:
    ///   - constraint: NSLayoutConstraint of the edge of self that is closest to parent view when hidden.
    ///   - isAnimated: true if modal should animate into/out of view, false if it should just appear.
    ///   - animationDirection: ModalAnimationDirection that the view should animate from.
    ///   - completionBlock: Completion block that will be enacted when UI update is complete.
    private func updateHiddenScreen(withConstraint constraint: NSLayoutConstraint, animated isAnimated: Bool, animateFrom animationDirection: ModalAnimationDirection?, completionBlock: (() -> ())?) {
        
        DispatchQueue.main.async { [weak self] in
            var updatedTopConstant: CGFloat = 0
            
            let isCurrentlyShowing = constraint.constant == 0
            
            if isCurrentlyShowing {
                if let animation = animationDirection {
                    switch animation {
                    case .bottom, .noAnimation: // If no animation it does not matter where view is from, so default to bottom
                        if let height = self?.superview?.frame.height {
                            updatedTopConstant = height
                        }
                    case .right:
                        if let width = self?.superview?.frame.width {
                            updatedTopConstant = width
                        }
                    }
                }
            } else {
                // Since view is about to show, unhide it
                self?.isHidden = false
            }
            
            constraint.constant = updatedTopConstant
            
            if isAnimated {
                UIView.animate(withDuration: 0.50,
                               animations: {
                                [weak self] in
                                self?.superview?.layoutIfNeeded()
                    },
                               completion: { (Bool) in
                                
                                // If view is dismissing, hide it when animation is complete
                                if isCurrentlyShowing {
                                    self?.isHidden = true
                                }
                                // If completion block was set, enact it
                                if let block = completionBlock {
                                    block()
                                }
                })
            } else {
                self?.superview?.layoutIfNeeded()
            }
        }
    }
    
    
    
}
