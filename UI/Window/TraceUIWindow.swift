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
        handleRotate()
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
    
    // MARK: - Private Properties
    
    /// Don't rotate manually if the application:
    ///
    /// - is running on iPad
    /// - supports all orientations
    /// - doesn't require full screen
    /// - has launch storyboard
    private lazy var shouldRotateManually: Bool = {
        let iPad = UIDevice.current.userInterfaceIdiom == .pad
        let application = UIApplication.shared
        let window = application.delegate?.window ?? nil
        let supportsAllOrientations = application.supportedInterfaceOrientations(for: window) == .all
        
        let info = Bundle.main.infoDictionary
        let requiresFullScreen = (info?["UIRequiresFullScreen"] as? NSNumber)?.boolValue == true
        let hasLaunchStoryboard = info?["UILaunchStoryboardName"] != nil
        
        if iPad && supportsAllOrientations && (requiresFullScreen == false) && hasLaunchStoryboard {
            return false
        }
        return true
    }()
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIWindow {
    
    func setupWindow() {
        windowLevel = UIWindowLevelAlert + 1
        backgroundColor = .clear
        isHidden = false
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(bringWindowToTop), name: .UIWindowDidBecomeVisible, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func bringWindowToTop(_ notification: Notification) {
        guard notification.object is TraceUIWindow == false else { return }
    
        /// Bring this window to top when another window is being shown
        isHidden = true
        isHidden = false
    }
    
    @objc func statusBarOrientationDidChange() {
        handleRotate()
    }
    
    @objc func applicationDidBecomeActive() {
        handleRotate()
    }
    
    func handleRotate() {
        let orientation = UIApplication.shared.statusBarOrientation
        
        if shouldRotateManually {
            transform = CGAffineTransform(rotationAngle: angle(for: orientation))
        }
        
        if let window = UIApplication.shared.windows.first, window is TraceUIWindow == false {
            let isPortraitOrRotatable = orientation.isPortrait || shouldRotateManually == false
            let windowSize = window.bounds.size
            frame.size.width = isPortraitOrRotatable ? windowSize.width : windowSize.height
            frame.size.height = isPortraitOrRotatable ? windowSize.height : windowSize.width
        }
        frame.origin = .zero
        
        DispatchQueue.main.async {
            self.setNeedsLayout()
        }
    }
    
    func angle(for orientation: UIInterfaceOrientation) -> CGFloat {
        switch orientation {
        case .portrait, .unknown: return 0
        case .landscapeLeft: return -.pi / 2
        case .landscapeRight: return .pi / 2
        case .portraitUpsideDown: return .pi
        }
    }
    
}
