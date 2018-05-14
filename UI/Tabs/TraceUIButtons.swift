//
//  TraceUIIconButton.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

internal typealias TraceUIButtonTapped = () -> ()

class TraceUIButton: UIButton, Viewing {
    static let edgeLength = TraceUITabView.height
    
    init(backgroundColor: UIColor, tapped: @escaping TraceUIButtonTapped) {
        self.tapped = tapped
        
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    private let tapped: TraceUIButtonTapped
    
    @objc private func handleTap() {
        tapped()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// e.g. buttons like: close, settings, collapse
class TraceUIIconButton: TraceUIButton {
    init(icon: UIImage, backgroundColor: UIColor, tapped: @escaping TraceUIButtonTapped) {
        super.init(backgroundColor: backgroundColor, tapped: tapped)
        
        setImage(icon, for: .normal)
        contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
