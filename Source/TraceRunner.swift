//
//  TracerRunner.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// Prepares a trace to be run, listens for when items fire, and handles finalizing the trace results
internal final class TraceRunner {
    
    // MARK: - Instantiation
    
    /// Creates a new runner and prepares an empty result to eventually report on.
    ///
    /// - Parameter trace: The `Traceable` trace to execute
    init(trace: Traceable) {
        self.trace = trace
        self.result = TraceResult(trace: trace)
    }
    
    // MARK: - API
    
    /// Executes any setup steps, then starts listening to items being fired and appends them
    /// appropriately into a `TraceResult` that can be displayed at the end of the trace.
    func start() {
        trace.setupBeforeStartingTrace?()
        
        listener = itemLogged.listen(wasFired: { [weak self] traceItem in
            self?.result.handleFiring(of: traceItem)
        })
    }
    
    /// Stops listening to items being fired, finalizes the trace report and returns it.
    func stop() -> TraceResult {
        if let listener = listener {
            itemLogged.remove(listener: listener)
        }
        
        result.finalize()
        return result
    }
    
    // MARK: - Internal Properties
    
    let itemLogged = TraceItemLoggedSignal()
    fileprivate(set) var result: TraceResult
    
    // MARK: - Private Properties
    
    fileprivate var trace: Traceable
    fileprivate var listener: TraceSignalListener?
    
}
