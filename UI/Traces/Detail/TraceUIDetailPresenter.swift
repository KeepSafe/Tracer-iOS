//
//  TraceUIDetailPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUIDetailPresenter: Presenting {
    
    init(view: TraceUIDetailView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Presenting
    
    func listenForChanges() {
        TraceUISignals.Traces.showTraceDetail.listen { traceToShow in
            self.view.configure(with: TraceUIDetailViewModel(trace: traceToShow))
        }
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIDetailView
    
}
