//
//  TraceUIContainer.swift
//  Tracer
//
//  Created by Rob Phillips on 5/16/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIContainer: Viewing {
    
    // MARK: - Instantiation
    
    init() {
        statusButton = TraceStatusButton()
        traceUIView = TraceUIView()
        traceUIPresenter = TraceUIPresenter(view: traceUIView)
        splitView = TraceUISplitView(resizableView: traceUIView)
        window = TraceUIWindow(rootViewController: splitView)
    }
    
    // MARK: - View Options
    
    func setupFixedSize() {
        setup(view: traceUIView)
    }
    
    func setupSplitView() {
        setup(view: splitView.view)
        splitView.view.alpha = 0
        setupStatusButton()
    }
    
    // MARK: - Animations
    
    func collapse() {
        let animator = TraceUIRevealAnimator(isExpanding: false, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    func expand() {
        let animator = TraceUIRevealAnimator(isExpanding: true, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    // MARK: - Status Button
    
    func configureStatusButton(state: TraceState?) {
        statusButton.configure(with: state)
    }
    
    func handleButtonDrag(with buttonDragTouchPoint: CGPoint, gestureState: UIGestureRecognizerState? = nil) {
        let touchPoint = window.convert(buttonDragTouchPoint, from: self.statusButton)
        
        // Can't go off left or right edge
        var newLeftConstant = touchPoint.x - TraceStatusButton.sizeLength / 2
        newLeftConstant = max(newLeftConstant, 0 + statusButtonPadding)
        newLeftConstant = min(newLeftConstant, UIScreen.main.bounds.size.width - TraceStatusButton.sizeLength - statusButtonPadding)
        
        // Can't go off top or bottom edge
        var newTopConstant = touchPoint.y - TraceStatusButton.sizeLength / 2
        let statusBarHeight: CGFloat = 20
        newTopConstant = max(newTopConstant, 0 + statusButtonPadding + statusBarHeight)
        newTopConstant = min(newTopConstant, UIScreen.main.bounds.size.height - TraceStatusButton.sizeLength - statusButtonPadding)
        
        let newPoint = CGPoint(x: newLeftConstant, y: newTopConstant)
        
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.statusButtonLeftConstraint?.constant = newPoint.x
            self.statusButtonTopConstraint?.constant = newPoint.y
            self.window.layoutIfNeeded()
        }, completion: nil)
        
        if gestureState == .ended {
            defaultsStore.set(NSStringFromCGPoint(newPoint), forKey: lastStatusButtonDragPointKey)
        }
    }
    
    // MARK: - Properties
    
    var rootViewController: UIViewController? {
        return splitView // TODO for fixed views: UIApplication.shared.keyWindow?.rootViewController
    }
    
    let traceUIView: TraceUIView
    
    // MARK: - Private Properties
    
    private let window: TraceUIWindow
    
    private let splitView: TraceUISplitView
    private let traceUIPresenter: TraceUIPresenter
    private let statusButton: TraceStatusButton
    
    private let statusButtonPadding: CGFloat = 5
    private var statusButtonLeftConstraint: NSLayoutConstraint?
    private var statusButtonTopConstraint: NSLayoutConstraint?
    
    private let defaultsStore = UserDefaults.standard
    private let lastStatusButtonDragPointKey = "traceUI.lastStatusButtonDragPointKey"
    
    private var savedStatusButtonPoint: CGPoint? {
        guard let pointString = defaultsStore.value(forKey: lastStatusButtonDragPointKey) as? String else { return nil }
        return CGPointFromString(pointString)
    }
    
}

// MARK: - Private API

private extension TraceUIContainer {
    
    // MARK: - View Setup
    
    func setup(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        window.addSubview(view)
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: window.topAnchor),
                                     view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: window.trailingAnchor)])
    }
    
    func setupStatusButton() {
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(statusButton)
        
        let buttonPoint: CGPoint
        if let savedButtonPoint = savedStatusButtonPoint {
            buttonPoint = savedButtonPoint
        } else {
            let topOffset = UIScreen.main.bounds.size.height - TraceStatusButton.sizeLength - statusButtonPadding * 2
            let leftOffset = statusButtonPadding * 2
            buttonPoint = CGPoint(x: leftOffset, y: topOffset)
        }
        
        let topConstraint = statusButton.topAnchor.constraint(equalTo: window.topAnchor, constant: buttonPoint.y)
        statusButtonTopConstraint = topConstraint
        let leftConstraint = statusButton.leftAnchor.constraint(equalTo: window.leftAnchor, constant: buttonPoint.x)
        statusButtonLeftConstraint = leftConstraint
        
        NSLayoutConstraint.activate([topConstraint,
                                     leftConstraint,
                                     statusButton.heightAnchor.constraint(equalToConstant: TraceStatusButton.sizeLength),
                                     statusButton.widthAnchor.constraint(equalToConstant: TraceStatusButton.sizeLength)])
    }
    
}

