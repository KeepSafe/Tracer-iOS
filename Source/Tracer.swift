//
//  Tracer.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public final class Tracer {
    
    // MARK: - Signals
    
    /// A signal to fire when a trace item fires; you'd fire this when any item needs
    /// to be logged or checked during a trace.
    ///
    /// E.g. if you were tracing analytics calls, you'd fire this for events and user property
    ///      changes and it would log that and compare it to the current trace being run
    public static let itemFired = TraceSignal<AnyTraceEquatable>()
    
    // MARK: - Instantiation
    
    public init() {}
    
    // MARK: - API
    
    /// Registers the given trace which can later be run or displayed in a list
    ///
    /// - Parameter trace: A `Traceable` (or concretely `Trace`) item to register; this should
    ///                    be done prior to attempting to start a trace, such as at app launch
    /// - Returns: `false` if the passed in trace is already registered, otherwise `true`
    @discardableResult
    public func register(trace: Traceable) -> Bool {
        // no-op if trace already registered by that name
        guard registeredTraces.first(where: { $0.name == trace.name }) == nil else {
            return false
        }
        
        registeredTraces.append(trace)
        return true
    }
    
    /// Attempts to start a trace by the given name, if it's been previously registered
    ///
    /// - Parameter name: The name of the `Traceable` or `Trace` item to start
    /// - Returns: `false` if the passed in trace isn't registered, otherwise `true`
    @discardableResult
    public func startTrace(named name: String) -> Bool {
        // no-op if no trace registered by that name
        guard let trace = registeredTraces.first(where: { $0.name == name }) else {
            return false
        }
        
        currentTrace = TraceRunner(trace: trace)
        currentTrace?.start()
        return true
    }
    
    /// Stops and clears the current trace
    ///
    /// - Returns: A `TraceReport`, if there was an active trace being run
    public func stopCurrentTrace() -> TraceReport? {
        guard let result = currentTrace?.stop() else { return nil }
        currentTrace = nil
        return TraceReport(result: result)
    }
    
    // MARK: - Private Properties
    
    fileprivate var registeredTraces = [Traceable]()
    fileprivate var currentTrace: TraceRunner?
    
}
