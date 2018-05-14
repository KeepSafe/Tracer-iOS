//
//  TracePassThroughView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// A transparent view that passes through its touches
final class TracePassThroughView: UIView {
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.clipsToBounds && !subview.isHidden &&
                subview.alpha > 0 && subview.isUserInteractionEnabled &&
                subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
