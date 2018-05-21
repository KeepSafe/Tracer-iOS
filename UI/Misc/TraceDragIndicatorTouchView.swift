//
//  TraceDragIndicatorTouchView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

typealias DragIndicatorTouched = (_ touch: UITouch) -> ()

/// Contains an invisible and visible area to make the touch area
/// tall enough to be easily dragged around (e.g. 44 points tall)
final class TraceDragIndicatorTouchView: UIView, Viewing {
    
    static let height: CGFloat = 44
    
    init(touched: @escaping DragIndicatorTouched) {
        self.touched = touched
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - Touch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touched(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Try to use predicted touches first, otherwise fall back to normal touch
        guard let predictedTouch = event?.predictedTouches(for: touch)?.last else {
            touched(touch)
            return
        }
        touched(predictedTouch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touched(touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touched(touch)
    }
    
    // MARK: - Private Properties
    
    private let touched: DragIndicatorTouched
    private let dragIndicatorView = DragIndicatorView()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private API

private extension TraceDragIndicatorTouchView {
    func setupView() {
        accessibilityLabel = "TraceUIDragToResizeView"
        
        backgroundColor = .clear
        
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dragIndicatorView)
        
        let superview = self
        NSLayoutConstraint.activate([dragIndicatorView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     dragIndicatorView.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     dragIndicatorView.rightAnchor.constraint(equalTo: superview.rightAnchor),
                                     dragIndicatorView.heightAnchor.constraint(equalToConstant: DragIndicatorView.height)])
    }
}

// MARK: - DragIndicatorView

private final class DragIndicatorView: UIView, Viewing {
    
    static let height: CGFloat = 20
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.TraceUI.darkBlueGray
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.white.set()
        let path = UIBezierPath(roundedRect: indicatorRect, cornerRadius: indicatorHeight / 2)
        path.stroke()
        path.fill()
    }
    
    // MARK: - Private Properties
    
    private lazy var indicatorRect: CGRect = { [unowned self] in
        return CGRect(x: (UIScreen.main.bounds.size.width - self.indicatorWidth) / 2,
                      y: (DragIndicatorView.height - self.indicatorHeight) / 2,
                      width: self.indicatorWidth,
                      height: self.indicatorHeight)
    }()
    
    private let indicatorHeight: CGFloat = 3
    private let indicatorWidth: CGFloat = 50
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
