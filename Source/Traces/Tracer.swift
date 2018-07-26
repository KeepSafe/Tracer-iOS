//
//  Tracer.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A signal that is fired any time the trace's overall state is changed, returning the state
public typealias TraceStateChangedSignal = TraceSignal<TraceState>

/// A signal that is fired any time an item was logged
public typealias TraceItemLoggedSignal = TraceSignal<TraceItem>

/// A tuple returned when a trace is started
public typealias TraceStarted = (currentState: TraceState, stateChanged: TraceStateChangedSignal, itemLogged: TraceItemLoggedSignal)

/// Main interface for registering and running traces
public final class Tracer {
    
    // MARK: - Instantiation
    
    /// Prepares a `Tracer` to be run and prepares an empty result to eventually report on.
    ///
    /// - Parameter trace: The `Traceable` trace to execute
    public init(trace: Traceable) {
        self.trace = trace
        self.result = TraceResult(trace: trace)
    }
    
    // MARK: - API
    
    /// Whether or not this tracer is currently running
    public var isRunning: Bool {
        return listener != nil
    }
    
    /// Executes any setup steps, then starts listening to items being fired and appends them
    /// appropriately into a `TraceResult` that can be displayed at the end of the trace.
    ///
    /// - Parameter canThrowAssertions: An override point where the app won't assert on failure; useful for enabling
    ///                                 different behaviors for unit tests versus running the same trace in the UI tool
    ///                                 (Default value is `true`).
    /// - Returns: A tuple `TraceStarted` with signals that can be listened to for trace changes
    @discardableResult
    public func start(canThrowAssertions: Bool = true) -> TraceStarted {
        result.canThrowAssertions = canThrowAssertions
        guard isRunning == false else {
            // Trace is already active, so just return signals
            return TraceStarted(currentState: result.state, stateChanged: result.stateChanged, itemLogged: itemLogged)
        }
        
        trace.setupBeforeStartingTrace?()
        
        listener = itemLogged.listen(wasFired: { [weak self] traceItem in
            self?.result.handleFiring(of: traceItem)
        })
        
        return TraceStarted(currentState: result.state, stateChanged: result.stateChanged, itemLogged: itemLogged)
    }
    
    /// Logs the given `TraceItem`; this is a no-op if no active trace is running
    ///
    /// - Parameter item: The `TraceItem` to log
    ///
    /// E.g. if you were tracing analytics calls, you'd fire this for events and user property
    ///      changes and it would log that and compare it to the current trace being run
    public func log(item: TraceItem) {
        itemLogged.fire(data: item)
    }
    
    /// Stops the current trace, removes all listeners, finalizes the trace report and returns it
    ///
    /// - Returns: A `TraceReport`, if there was an active trace being run
    @discardableResult
    public func stop() -> TraceReport {
        if let listener = listener {
            itemLogged.remove(listener: listener)
            self.listener = nil
        }
        
        result.finalize()
        return TraceReport(result: result)
    }
    
    // MARK: - Internal Properties
    
    fileprivate(set) var result: TraceResult
    
    // MARK: - Private Properties
    
    fileprivate var trace: Traceable
    fileprivate var listener: TraceSignalListener?
    
    fileprivate let itemLogged = TraceItemLoggedSignal()
    
}
