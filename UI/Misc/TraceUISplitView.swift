//
//  TraceUISplitView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// A vertically resizable split view container that has a transparent
/// area above the split view that can pass touches through
final class TraceUISplitView: UIViewController, Viewing {
    
    // MARK: - Instantiation
    
    /// Creates a vertically resizable split view container that has a transparent
    /// area above the split view that can pass touches through
    ///
    /// - Parameters:
    ///   - resizableView: A `UIView` to make resizable
    ///   - minimumTransparentViewHeight: the minimum height of the transparent area, defaulting to `50`
    ///   - minimumResizableViewHeight: the minimum height of the resizable area, defaulting to `200`
    init(resizableView: UIView, minimumTransparentViewHeight: CGFloat = 50, minimumResizableViewHeight: CGFloat = 200) {
        self.minimumTransparentViewHeight = minimumTransparentViewHeight
        self.minimumResizableViewHeight = minimumResizableViewHeight
        self.resizableView = resizableView
        
        super.init(nibName: nil, bundle: nil)
        
        setupView()
        setupNotifications()
    }
    
    override func loadView() {
        view = TracePassThroughView()
    }
    
    // MARK: - Private Properties
    
    private let minimumTransparentViewHeight: CGFloat
    private let minimumResizableViewHeight: CGFloat
    
    private var dragViewTopConstraint: NSLayoutConstraint?
    private lazy var dragIndicatorView: TraceDragIndicatorTouchView = { [unowned self] in
        let view = TraceDragIndicatorTouchView(touched: { touch in
            self.resizeView(with: touch)
        })
        return view
    }()
    private let resizableView: UIView
    
    private let defaultTransparentViewHeight: CGFloat = 200
    private let defaultsStore = UserDefaults.standard
    private let lastTransparentViewHeightKey = "traceUISplitView.lastTransparentViewHeightKey"
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUISplitView {
    
    // MARK: - View Setup
    
    func setupView() {
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        resizableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dragIndicatorView)
        view.addSubview(resizableView)
        
        var transparentViewHeight = defaultsStore.value(forKey: lastTransparentViewHeightKey) as? CGFloat ?? defaultTransparentViewHeight
        transparentViewHeight = constrainedHeightValue(from: transparentViewHeight)
        
        let topAnchor = dragIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: transparentViewHeight)
        topAnchor.priority = .defaultLow // ensure this constraint gives if screen rotates
        dragViewTopConstraint = topAnchor
        NSLayoutConstraint.activate([topAnchor,
                                     dragIndicatorView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     dragIndicatorView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     dragIndicatorView.heightAnchor.constraint(equalToConstant: TraceDragIndicatorTouchView.height)])
        
        NSLayoutConstraint.activate([resizableView.topAnchor.constraint(equalTo: dragIndicatorView.bottomAnchor),
                                     resizableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     resizableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     resizableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    // MARK: - Orientations
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    @objc func statusBarOrientationDidChange() {
        ensureConstraintsAreMaintained()
    }
    
    func ensureConstraintsAreMaintained() {
        resizeView(with: dragIndicatorView.frame.origin.y)
    }
    
    // MARK: - Resizing
    
    func resizeView(with touch: UITouch) {
        let touchPoint = touch.location(in: view)

        resizeView(with: touchPoint.y)
    }
    
    func resizeView(with topYOrigin: CGFloat) {
        let newTransparentViewHeight = constrainedHeightValue(from: topYOrigin)
    
        // Store this preferred height
        defaultsStore.setValue(newTransparentViewHeight, forKey: lastTransparentViewHeightKey)
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.dragViewTopConstraint?.constant = newTransparentViewHeight
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // Ensures the passed in height value doesn't exceed our limits
    func constrainedHeightValue(from heightValue: CGFloat) -> CGFloat {
        var newTransparentViewHeight = heightValue
        
        // Set some resize boundaries
        // don't cover top of screen
        newTransparentViewHeight = max(minimumTransparentViewHeight, newTransparentViewHeight)
        // but don't collapse too much
        newTransparentViewHeight = min(UIScreen.main.bounds.size.height - minimumResizableViewHeight, newTransparentViewHeight)
        
        return newTransparentViewHeight
    }
    
}
