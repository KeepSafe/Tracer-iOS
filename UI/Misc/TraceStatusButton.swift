//
//  TraceStatusButton.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceStatusButton: TraceUIIconButton {
    // e.g. height or width
    static let sizeLength: CGFloat = 50
    
    init() {
        super.init(icon: .inBundle(named: "TraceIcon"), backgroundColor: UIColor.TraceUI.StatusButton.blueGray, tapped: {
            TraceUISignals.UI.expandTool.fire(data: nil)
        })
        
        setupView()
    }
    
    func configure(with state: TraceState?) {
        guard let state = state else {
            changeColor(to: UIColor.TraceUI.StatusButton.blueGray)
            return
        }
        changeColor(to: state.toColor)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private API

private extension TraceStatusButton {
    func setupView() {
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
