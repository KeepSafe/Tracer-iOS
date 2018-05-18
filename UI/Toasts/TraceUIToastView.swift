//
//  TraceUIToastView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/18/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIToastView: UIView, Viewing {
    
    init(viewModel: TraceUIToastViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - Private Properties
    
    private let viewModel: TraceUIToastViewModel
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

private extension TraceUIToastView {
    
    func setupView() {
        isUserInteractionEnabled = false
        
        let attributedText = NSMutableAttributedString(string: "\(viewModel.loggedItem.item)")
        if let properties = viewModel.loggedItem.properties {
            attributedText.append(NSAttributedString(string: "\n\n"))
            attributedText.append(properties.attributedLoggerDescription(fontSize: 12))
        }
        textLabel.attributedText = attributedText
        
        backgroundColor = UIColor.TraceUI.darkBlueGray.withAlphaComponent(0.7)
        layer.cornerRadius = 5
        
        let screenSize = UIScreen.main.bounds.size
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
        let superview = self
        NSLayoutConstraint.activate([textLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: 8),
                                     textLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -8),
                                     textLabel.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 10),
                                     textLabel.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -10)])
        
        let maxWidth: CGFloat = screenSize.width * 0.875
        let maxHeight: CGFloat = screenSize.height * 0.875
        NSLayoutConstraint.activate([superview.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
                                     superview.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight),
                                     superview.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                                     superview.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)])
    }
    
}
