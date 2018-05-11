//
//  TraceUIStartStopButton.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

enum StartStopButtonState {
    case hidden, readyToStart, started, stopped
}

final class TraceUIStartStopButton: UIView, Viewing {
    
    // MARK: - Instantiation
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - API
    
    func configure(traceName: String, state: StartStopButtonState) {
        guard state != .hidden else { return }
        
        traceNameLabel.text = traceName
        UIView.animate(withDuration: TraceUI.Animation.duration) {
            if state == .stopped {
                self.startTraceButton.alpha = 0
                self.stopTraceButton.alpha = 0
            } else {
                self.startTraceButton.alpha = state == .readyToStart ? 1 : 0
                self.stopTraceButton.alpha = state == .started ? 1 : 0
            }
        }
    }
    
    // MARK: - Properties
    
    var centeringDistance: CGFloat {
        return (leftPadding + edgeLength) / 2
    }
    
    // MARK: - Private Properties
    
    private lazy var startTraceButton: TraceUIIconButton = {
        let button = TraceUIIconButton(icon: .inBundle(named: "StartTraceIcon"), backgroundColor: .clear, tapped: {
            TraceUISignals.UI.startTrace.fire(data: nil)
        })
        return button
    }()
    
    private lazy var stopTraceButton: TraceUIIconButton = {
        let button = TraceUIIconButton(icon: .inBundle(named: "StopTraceIcon"), backgroundColor: .clear, tapped: {
            TraceUISignals.UI.stopTrace.fire(data: nil)
        })
        button.alpha = 0
        return button
    }()
    
    private lazy var traceNameLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private var state: StartStopButtonState = .readyToStart
    private let leftPadding: CGFloat = 10
    private let edgeLength: CGFloat = 25
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIStartStopButton {
    
    func setupView() {
        traceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        startTraceButton.translatesAutoresizingMaskIntoConstraints = false
        stopTraceButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(traceNameLabel)
        addSubview(startTraceButton)
        addSubview(stopTraceButton)
        
        let superview = self
        NSLayoutConstraint.activate([traceNameLabel.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                                     traceNameLabel.rightAnchor.constraint(equalTo: superview.rightAnchor)])
        
        NSLayoutConstraint.activate([startTraceButton.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                                     startTraceButton.heightAnchor.constraint(equalToConstant: edgeLength),
                                     startTraceButton.widthAnchor.constraint(equalToConstant: edgeLength),
                                     startTraceButton.rightAnchor.constraint(equalTo: traceNameLabel.leftAnchor, constant: -leftPadding),
                                     startTraceButton.leftAnchor.constraint(equalTo: superview.leftAnchor)])
        NSLayoutConstraint.activate([stopTraceButton.centerYAnchor.constraint(equalTo: startTraceButton.centerYAnchor),
                                     stopTraceButton.heightAnchor.constraint(equalToConstant: edgeLength),
                                     stopTraceButton.widthAnchor.constraint(equalToConstant: edgeLength),
                                     stopTraceButton.rightAnchor.constraint(equalTo: startTraceButton.rightAnchor),
                                     stopTraceButton.leftAnchor.constraint(equalTo: startTraceButton.leftAnchor)])
    }
    
}
