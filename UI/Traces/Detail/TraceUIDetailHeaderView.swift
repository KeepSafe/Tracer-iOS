//
//  TraceUIDetailHeaderView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIDetailHeaderView: UIView, Viewing {
    
    // MARK: - Instantiation
    
    init(setupSteps: String) {
        self.setupSteps = setupSteps
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - Private Properties
    
    private let setupSteps: String
    
    private lazy var setupStepsLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.text = self.setupSteps
        return label
    }()
    
    // MARK: - Unsupported Initializers
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIDetailHeaderView {
    
    func setupView() {
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        setupStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(setupStepsLabel)
        
        let superview = self
        NSLayoutConstraint.activate([setupStepsLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: 15),
                                     setupStepsLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     setupStepsLabel.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.7),
                                     setupStepsLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor)])
    }
    
}
