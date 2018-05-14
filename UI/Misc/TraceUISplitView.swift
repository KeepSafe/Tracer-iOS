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
final class TraceUISplitView: UIView {
    
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
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - Private Properties
    
    private let minimumTransparentViewHeight: CGFloat
    private let minimumResizableViewHeight: CGFloat
    
    private let transparentView = TracePassThroughView()
    private lazy var dragIndicatorView: TraceDragIndicatorTouchView = { [unowned self] in
        let view = TraceDragIndicatorTouchView(touched: { touch in
            self.resizeView(with: touch)
        })
        return view
    }()
    private let resizableView: UIView

    private var transparentViewHeightConstraint: NSLayoutConstraint?
    
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
        transparentView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        resizableView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(transparentView)
        addSubview(dragIndicatorView)
        addSubview(resizableView)
        
        let superview = self
        
        let transparentViewHeight = defaultsStore.value(forKey: lastTransparentViewHeightKey) as? CGFloat ?? defaultTransparentViewHeight
        let heightAnchor = transparentView.heightAnchor.constraint(equalToConstant: transparentViewHeight)
        transparentViewHeightConstraint = heightAnchor
        NSLayoutConstraint.activate([transparentView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     transparentView.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     transparentView.rightAnchor.constraint(equalTo: superview.rightAnchor),
                                     heightAnchor])
        
        NSLayoutConstraint.activate([dragIndicatorView.topAnchor.constraint(equalTo: transparentView.bottomAnchor),
                                     dragIndicatorView.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     dragIndicatorView.rightAnchor.constraint(equalTo: superview.rightAnchor),
                                     dragIndicatorView.heightAnchor.constraint(equalToConstant: TraceDragIndicatorTouchView.height)])
        
        NSLayoutConstraint.activate([resizableView.topAnchor.constraint(equalTo: dragIndicatorView.bottomAnchor),
                                     resizableView.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     resizableView.rightAnchor.constraint(equalTo: superview.rightAnchor),
                                     resizableView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)])
    }
    
    // MARK: - Resizing
    
    func resizeView(with touch: UITouch) {
        guard let superview = superview else { return }
        
        let touchPoint = touch.location(in: superview)
        var newTransparentViewHeight = touchPoint.y
        
        // Set some resize boundaries
        // don't cover top of screen
        newTransparentViewHeight = max(minimumTransparentViewHeight, newTransparentViewHeight)
        // but don't collapse too much
        newTransparentViewHeight = min(UIScreen.main.bounds.size.height - minimumResizableViewHeight, newTransparentViewHeight)

        // Store this preferred height
        defaultsStore.setValue(newTransparentViewHeight, forKey: lastTransparentViewHeightKey)
        
        layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.transparentViewHeightConstraint?.constant = newTransparentViewHeight
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}
