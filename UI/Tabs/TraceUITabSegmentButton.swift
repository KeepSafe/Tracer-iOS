//
//  TraceUITabSegmentButton.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUITabSegmentButton: UIView, Viewing {
    
    static let width: CGFloat = 250
    
    // MARK: - Instantiation
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - API
    
    func configure(loggerTabActive: Bool) {
        loggerButton.backgroundColor = loggerTabActive ? .white : UIColor.TraceUI.lightGray
        loggerButton.titleLabel?.font = loggerTabActive ? boldFont : font
        tracesButton.backgroundColor = loggerTabActive ? UIColor.TraceUI.lightGray : .white
        tracesButton.titleLabel?.font = loggerTabActive ? font : boldFont
    }
    
    // MARK: - Private Properties
    
    private lazy var loggerButton: TraceUIButton = { [unowned self] in
        let button = TraceUIButton(backgroundColor: .white, tapped: {
            TraceUISignals.UI.showLogger.fire(data: nil)
        })
        button.setTitle("Logger", for: .normal)
        button.setTitleColor(UIColor.TraceUI.darkGray, for: .normal)
        button.titleLabel?.font = boldFont
        return button
    }()
    
    private lazy var tracesButton: TraceUIButton = { [unowned self] in
        let button = TraceUIButton(backgroundColor: UIColor.TraceUI.lightGray, tapped: {
            TraceUISignals.UI.showTraces.fire(data: nil)
        })
        button.setTitle("Start a trace", for: .normal)
        button.setTitleColor(UIColor.TraceUI.darkGray, for: .normal)
        button.titleLabel?.font = font
        return button
    }()
    
    private let font = UIFont.systemFont(ofSize: 14)
    private let boldFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private API

private extension TraceUITabSegmentButton {
    
    func setupView() {
        backgroundColor = UIColor.TraceUI.lightGray
        
        loggerButton.translatesAutoresizingMaskIntoConstraints = false
        tracesButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loggerButton)
        addSubview(tracesButton)
        
        let superview = self
        
        let width: CGFloat = TraceUITabSegmentButton.width / 2
        NSLayoutConstraint.activate([loggerButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     loggerButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     loggerButton.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     loggerButton.widthAnchor.constraint(equalToConstant: width)])
        
        NSLayoutConstraint.activate([tracesButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     tracesButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     tracesButton.leftAnchor.constraint(equalTo: loggerButton.rightAnchor),
                                     tracesButton.widthAnchor.constraint(equalToConstant: width)])
    }
    
}
