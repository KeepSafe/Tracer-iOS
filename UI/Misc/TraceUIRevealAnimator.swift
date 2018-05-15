//
//  TraceUIRevealAnimator.swift
//  Tracer
//
//  Created by Rob Phillips on 5/15/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIRevealAnimator: NSObject {
    
    init(isExpanding: Bool, triggeringButton: UIView, expandableView: UIView) {
        self.isExpanding = isExpanding
        self.triggeringButton = triggeringButton
        self.expandableView = expandableView
        
        super.init()
        
        setupAnimation()
    }
    
    func start() {
        expandableView.alpha = 1
        expandableView.layer.mask = mask
        mask.frame = expandableView.layer.bounds
        mask.add(expandCollapseAnimation, forKey: "reveal")
        
        fadeInOrOut()
    }
    
    private let isExpanding: Bool
    private let triggeringButton: UIView
    private let expandableView: UIView
    private let mask = CAShapeLayer()
    private let animationDuration: Double = 0.5
    
    private lazy var expandCollapseAnimation: CABasicAnimation = { [unowned self] in
        let animation = CABasicAnimation(keyPath: "path") // animate the mask's path
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = self.animationDuration
        animation.delegate = self
        return animation
    }()
}

extension TraceUIRevealAnimator: CAAnimationDelegate {
    dynamic func animationDidStop(_: CAAnimation, finished: Bool) {
        expandableView.mask = nil
        expandCollapseAnimation.delegate = nil
    }
}

private extension TraceUIRevealAnimator {
    func setupAnimation() {
        let mainScreenSize = UIScreen.main.bounds.size
        let maxRadius = max(mainScreenSize.height, mainScreenSize.width)
        let startRadius = isExpanding ? 0 : maxRadius
        let startCenter = isExpanding ? triggeringButton.center : expandableView.center
        let endRadius = isExpanding ? maxRadius : 0
        let endCenter = isExpanding ? expandableView.center : triggeringButton.center
        
        let startPath = CGPath(ellipseIn: rectForCircle(centeredAt: startCenter, with: startRadius), transform: nil)
        let endPath = CGPath(ellipseIn: rectForCircle(centeredAt: endCenter, with: endRadius), transform: nil)
        mask.path = endPath
        expandCollapseAnimation.fromValue = startPath
        expandCollapseAnimation.toValue = endPath
    }
    
    func rectForCircle(centeredAt origin: CGPoint, with radius: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: .zero).insetBy(dx: -radius, dy: -radius)
    }
    
    func fadeInOrOut() {
        let duration = isExpanding ? animationDuration / 4 : animationDuration
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.triggeringButton.alpha = self.isExpanding ? 0 : 1
        }, completion: nil)
    }
}
