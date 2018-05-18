//
//  TraceUIToastPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/18/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIToastPresenter: Presenting {
    
    init(queue: TraceUIToastQueue = TraceUIToastQueue()) {
        self.queue = queue
        
        listenForChanges()
    }
    
    // MARK: - Private Properties
    
    private let queue: TraceUIToastQueue
    private var showToasts = true
    
}

private extension TraceUIToastPresenter {
    func listenForChanges() {
        TraceUISignals.Toasts.enable.listen { _ in
            self.showToasts = true
        }
        TraceUISignals.Toasts.queue.listen { loggedItem in
            guard self.showToasts else { return }
            let viewModel = TraceUIToastViewModel(loggedItem: loggedItem)
            self.queue.queue(toast: TraceUIToast(viewModel: viewModel))
        }
        TraceUISignals.Toasts.disable.listen { _ in
            self.showToasts = false
            self.queue.cancelAll()
        }
    }
}
