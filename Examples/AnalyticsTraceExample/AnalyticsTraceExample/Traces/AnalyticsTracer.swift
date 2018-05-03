//
//  AnalyticsTracer.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

final class AnalyticsTracer {
    
    // MARK: - API
    
    func start(trace traceToRun: AnalyticsTrace) {
        let analyticsTrace = traceToRun.toTrace
        let tracer = Tracer()
        tracer.register(trace: analyticsTrace)
        guard let (currentState, stateChangedSignal, itemLoggedSignal) = tracer.start(trace: analyticsTrace) else { return }
    
        print("\n\n---> TRACE STARTED: \(analyticsTrace.name)")
        print("---> Current trace state: \(currentState)")
        
        // Optionally, listen to changes in this trace (and you can remove the listener at any point)
        itemLoggedListener = itemLoggedSignal.listen { traceItem in
            print("---> Trace item logged: \(traceItem)")
        }
        stateChangedListener = stateChangedSignal.listen { traceState in
            print("---> Trace state updated to: \(traceState.rawValue)")
            print("---> Trace state description: \(traceState)")
        }
        
        activeTracer = tracer
    }
    
    func stopActiveTrace() -> TraceReport? {
        // FYI: signal listeners are automatically removed when stopped
        let report = activeTracer?.stop()
        return report
    }
    
    // MARK: - Properties
    
    fileprivate(set) var activeTracer: Tracer?
    
    // MARK: - Private Properties
    
    fileprivate var stateChangedListener: TraceSignalListener?
    fileprivate var itemLoggedListener: TraceSignalListener?
    
}
