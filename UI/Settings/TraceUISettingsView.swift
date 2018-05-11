//
//  TraceUISettingsView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

struct TraceUISettingsView: Viewing {
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Configuration
    
    /// Note: this is an append-only function by nature of `UIAlertController`'s design
    func configure(with viewModel: TraceUISettingsViewModel) {
        for action in viewModel.actions {
            guard alertController.actions.first(where: { $0.title == action.title }) == nil else { return }
            alertController.addAction(action)
        }
    }
    
    // MARK: - Properties
    
    let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
    
}
