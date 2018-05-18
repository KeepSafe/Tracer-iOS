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
        toastPresenter = TraceUIToastPresenter()
        window = TraceUIWindow(rootViewController: splitView)
        
        setupView()
        setupNotifications()
    }
    
    // MARK: - View Options
    
    func show() {
        window.isHidden = false
        UIView.animate(withDuration: TraceAnimation.duration, delay: 0, options: [.beginFromCurrentState], animations: {
            self.window.alpha = 1
        })
    }
    
    func hide() {
        window.isHidden = false
        UIView.animate(withDuration: TraceAnimation.duration, delay: 0, options: [.beginFromCurrentState], animations: {
            self.window.alpha = 0
        }) { _ in
            self.window.isHidden = true
        }
    }
    
    // MARK: - Animations
    
    func collapse() {
        isCollapsed = true
        let animator = TraceUIRevealAnimator(isExpanding: false, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    func expand() {
        isCollapsed = false
        let animator = TraceUIRevealAnimator(isExpanding: true, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    // MARK: - Toasts
    
    func show(toast: TraceUIToast) {
        guard isCollapsed else { return }
        
        let toastView = toast.view
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        window.layoutIfNeeded()
        window.addSubview(toastView)
        NSLayoutConstraint.activate([toastView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -20),
                                     toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor)])
        window.layoutIfNeeded()
        
        currentToast = toast
        UIView.animate(withDuration: TraceAnimation.duration, delay: 0, options: [.beginFromCurrentState], animations: {
            toastView.alpha = 1
        }) { _ in
            // Display it for a couple of seconds
            UIView.animate(withDuration: 2, animations: {
                toastView.alpha = 1.001
            }, completion: { _ in
                UIView.animate(withDuration: TraceAnimation.duration, animations: {
                    toastView.alpha = 0
                }, completion: { _ in
                    self.currentToast = nil
                    toast.finish()
                })
            })
        }
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
    
    var rootViewController: UIViewController {
        return splitView
    }
    
    let traceUIView: TraceUIView
    
    // MARK: - Private Properties
    
    private let window: TraceUIWindow
    
    private let toastPresenter: TraceUIToastPresenter
    private let splitView: TraceUISplitView
    private let traceUIPresenter: TraceUIPresenter
    private let statusButton: TraceStatusButton
    
    private let statusButtonPadding: CGFloat = 5
    private var statusButtonLeftConstraint: NSLayoutConstraint?
    private var statusButtonTopConstraint: NSLayoutConstraint?
    
    private var currentToast: TraceUIToast?
    
    private var isCollapsed = true {
        didSet {
            if isCollapsed {
                TraceUISignals.Toasts.enable.fire(data: nil)
            } else {
                TraceUISignals.Toasts.disable.fire(data: nil)
                
                currentToast?.view.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.currentToast?.view.alpha = 0
                }, completion: { _ in
                    self.currentToast?.finish()
                    self.currentToast = nil
                })
            }
        }
    }
    
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
    
    func setupView() {
        window.alpha = 0
        setup(view: splitView.view)
        splitView.view.alpha = 0
        setupStatusButton()
    }
    
    func setup(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        window.addSubview(view)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
                                         view.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor),
                                         view.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor),
                                         view.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor)])
        } else {
            NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: window.topAnchor),
                                         view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                                         view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                                         view.trailingAnchor.constraint(equalTo: window.trailingAnchor)])
        }
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
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func statusBarOrientationDidChange() {
        ensureStatusButtonStaysOnScreen()
    }
    
    @objc func applicationDidBecomeActive() {
        ensureStatusButtonStaysOnScreen()
    }
    
    // Handle rotations
    func ensureStatusButtonStaysOnScreen() {
        let mainBounds = UIScreen.main.bounds.size
        let buttonOrigin = statusButton.frame.origin
        let buttonPlusPadding = TraceStatusButton.sizeLength + statusButtonPadding
        
        if (buttonOrigin.x < statusButtonPadding || buttonOrigin.x > mainBounds.width - buttonPlusPadding) ||
           (buttonOrigin.y < statusButtonPadding || buttonOrigin.y > mainBounds.height - buttonPlusPadding) {
            let x = min(mainBounds.width - buttonPlusPadding, max(buttonOrigin.x, statusButtonPadding))
            let y = min(mainBounds.height - buttonPlusPadding, max(buttonOrigin.y, statusButtonPadding))
            
            window.layoutIfNeeded()
            UIView.animate(withDuration: TraceAnimation.duration) {
                self.statusButtonLeftConstraint?.constant = x
                self.statusButtonTopConstraint?.constant = y
                self.window.layoutIfNeeded()
            }
            defaultsStore.set(NSStringFromCGPoint(CGPoint(x: x, y: y)), forKey: lastStatusButtonDragPointKey)
        }
    }
    
}

