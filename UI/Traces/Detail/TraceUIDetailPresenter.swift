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
            
            
            self.simulateTraceRunning()
        }
        
        TraceUISignals.Traces.started.listen { tuple in
            self.listenForTraceChanges(with: tuple.started)
        }
    }
    
    // TODO: temp, remove this
    private func simulateTraceRunning() {
        guard let tracer = tracer else { return }
    
        let started = tracer.start()
        TraceUISignals.Traces.started.fire(data: (trace: tracer.result.trace, started: started))
        
        let ti1 = TraceItem(type: "event", itemToMatch: AnyTraceEquatable("logicCheckpointOne"))
        let ti2 = TraceItem(type: "event", itemToMatch: AnyTraceEquatable("logicCheckpointTwo"))
        let ti3 = TraceItem(type: "event", itemToMatch: AnyTraceEquatable("logicCheckpointThree"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            tracer.log(item: ti1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            tracer.log(item: ti2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            tracer.log(item: ti3)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            tracer.stop()
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
        
        print("initial state: \(traceStarted.currentState)")
        
        traceStarted.itemLogged.listen { traceItem in
            print("logged \(traceItem)")
            TraceUISignals.Traces.itemLogged.fire(data: traceItem)
        }
        
        traceStarted.stateChanged.listen { traceState in
            print("trace state changed: \(traceState)")
            TraceUISignals.Traces.stateChanged.fire(data: traceState)
            
            guard let states = self.tracer?.result.statesForItemsToMatch else { return }
            let viewModel = TraceUIDetailViewModel(trace: trace,
                                                   isTraceRunning: true,
                                                   statesForItemsToMatch: states)
            self.view.configure(with: viewModel)
        }
    }
    
}
