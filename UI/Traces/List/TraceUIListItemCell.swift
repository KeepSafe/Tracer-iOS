//
//  TraceUIListItemCell.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIListItemCell: UITableViewCell, Viewing {
    
    static let identifier = "\(TraceUIListItemCell.self)"
    static let height: CGFloat = 60
    
    // MARK: - Instantiation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    // MARK: - API
    
    func configure(with trace: Traceable) {
        accessoryType = .disclosureIndicator
        textLabel?.text = trace.name
    }
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIListItemCell {
    
    func setupView() {
        NSLayoutConstraint.activate([contentView.heightAnchor.constraint(equalToConstant: TraceUIListItemCell.height)])
    }
    
}
