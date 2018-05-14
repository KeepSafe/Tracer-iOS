//
//  TracePassThroughView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// A transparent view that passes through its touches
class TracePassThroughView: UIView, Viewing {
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
