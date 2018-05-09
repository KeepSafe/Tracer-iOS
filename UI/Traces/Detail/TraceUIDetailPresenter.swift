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
        TraceUISignals.Traces.showDetail.listen { traceToShow in
            self.trace = traceToShow
            let newTracer = Tracer(trace: traceToShow)
            self.tracer = newTracer
            let viewModel = TraceUIDetailViewModel(trace: traceToShow,
                                                   isTraceRunning: false,
                                                   statesForItemsToMatch: newTracer.result.statesForItemsToMatch)
            self.view.configure(with: viewModel)
        }
        
        TraceUISignals.Traces.started.listen { tuple in
            self.listenForTraceChanges(with: tuple.started)
        }
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIDetailView
    private var tracer: Tracer?
    private var trace: Traceable?
}

// MARK: - Servicing

extension TraceUIDetailPresenter: Servicing {
    
    func listenForTraceChanges(with traceStarted: TraceStarted) {
        guard let trace = trace else { return }
        
        traceStarted.itemLogged.listen { traceItem in
            TraceUISignals.Traces.itemLogged.fire(data: traceItem)
        }
        
        traceStarted.stateChanged.listen { traceState in
            TraceUISignals.Traces.stateChanged.fire(data: traceState)
            
            guard let states = self.tracer?.result.statesForItemsToMatch else { return }
            let viewModel = TraceUIDetailViewModel(trace: trace,
                                                   isTraceRunning: true,
                                                   statesForItemsToMatch: states)
            self.view.configure(with: viewModel)
        }
    }
    
}
