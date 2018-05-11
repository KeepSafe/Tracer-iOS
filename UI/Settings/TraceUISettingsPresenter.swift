//
//  TraceUISettingsPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUISettingsPresenter: Presenting {
    
    init(view: TraceUISettingsView) {
        self.view = view
        
        view.configure(with: TraceUISettingsViewModel(actions: defaultActions))
        listenForChanges()
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUISettingsView
    
    private lazy var defaultActions: [UIAlertAction] = {
        let exportLogAction = UIAlertAction(title: "Export log", style: .default, handler: { _ in
            TraceUISignals.UI.exportLog.fire(data: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        return [exportLogAction, cancel]
    }()
}

private extension TraceUISettingsPresenter {
    func listenForChanges() {
        TraceUISignals.UI.settingsAdded.listen { actions in
            let viewModel = TraceUISettingsViewModel(actions: actions) // this is append only
            self.view.configure(with: viewModel)
        }
    }
}
