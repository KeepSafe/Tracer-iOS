//
//  TraceStatusButton.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// Draggable trace status button
final class TraceStatusButton: TraceUIIconButton {
    // e.g. height or width
    static let sizeLength: CGFloat = 50
    
    // MARK: - Instantiation
    
    init() {
        super.init(icon: .inBundle(named: "TraceIcon"), backgroundColor: UIColor.TraceUI.StatusButton.blueGray, tapped: {
            TraceUISignals.UI.expandTool.fire(data: nil)
        })
        
        setupView()
    }
    
    // MARK: - View Model
    
    func configure(with state: TraceState?) {
        guard let state = state else {
            changeColor(to: UIColor.TraceUI.StatusButton.blueGray)
            return
        }
        changeColor(to: state.toColor)
    }
    
    // MARK: - Private Properties
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = { [unowned self] in
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesture.minimumPressDuration = 0.2
        gesture.cancelsTouchesInView = true
        return gesture
    }()
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private API

private extension TraceStatusButton {
    func setupView() {
        addGestureRecognizer(longPressGesture)
        
        layer.masksToBounds = false
        layer.cornerRadius = TraceStatusButton.sizeLength / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 6
    }
    
    func changeColor(to color: UIColor) {
        UIView.transition(with: self, duration: TraceUI.Animation.duration, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.backgroundColor = color
        }, completion: nil)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let touchPoint = gesture.location(in: self) // touch point in this view coordinate space
        
        func broadcastTouchPoint(state: UIGestureRecognizerState) {
            TraceUISignals.UI.statusButtonDragged.fire(data: (touchPoint: touchPoint, gestureState: state))
        }
        
        switch gesture.state {
        case .began:
            broadcastTouchPoint(state: .began)
            animateDragging(beginning: true)
        case .changed:
            broadcastTouchPoint(state: .changed)
        case .cancelled, .ended:
            broadcastTouchPoint(state: .ended)
            animateDragging(beginning: false)
        default:
            break
        }
    }
    
    func animateDragging(beginning: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.transform = beginning ? CGAffineTransform(scaleX: 2, y: 2) : .identity
            self.alpha = beginning ? 0.5 : 1
        }, completion: nil)
    }
}

// MARK: - TraceState Extension

private extension TraceState {
    var toColor: UIColor {
        let statusStruct = UIColor.TraceUI.StatusButton.self
        switch self {
        case .waiting: return statusStruct.yellow
        case .passing: return statusStruct.green
        case .passed: return statusStruct.green
        case .failed: return statusStruct.red
        }
    }
}
