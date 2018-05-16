//
//  TraceUIWindow.swift
//  Tracer
//
//  Created by Rob Phillips on 5/15/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// A transparent view that passes through its touches
/// since the window hitTest returns nil for this class type
class TracePassThroughView: UIView, Viewing {}

/// Container window for the floating TraceUI tool
final class TraceUIWindow: UIWindow {
    
    // MARK: - Instantiation
    
    init(rootViewController: UIViewController) {
        super.init(frame: UIScreen.main.bounds)
        
        setupWindow()
        registerNotifications()
        self.rootViewController = rootViewController
    }
    
    // MARK: - Pass Through Touches
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        if hitView == self || hitView is TracePassThroughView {
            return nil
        }
        return hitView
    }
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIWindow {
    
    func setupWindow() {
        windowLevel = CGFloat.greatestFiniteMagnitude
        backgroundColor = .clear
        isHidden = false
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(bringWindowToTop), name: .UIWindowDidBecomeVisible, object: nil)
    }
    
    @objc func bringWindowToTop(_ notification: Notification) {
        guard isHidden == false, notification.object is TraceUIWindow == false else { return }
    
        /// Bring this window to top when another window is being shown
        isHidden = true
        isHidden = false
    }
    
}
