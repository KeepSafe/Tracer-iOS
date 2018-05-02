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
    /// - Parameter trace: The `Traceable` or `Trace` item to start
    /// - Returns: `nil` if the passed in trace isn't registered, otherwise returns
    ///            a tuple `TraceStarted` with signals that can be listened to for trace changes
    ///
    /// Note: this is a no-op if there's an active trace running
    @discardableResult
    public func start(trace: Traceable) -> TraceStarted? {
        return startTrace(named: trace.name)
    }
    
    /// Attempts to start a trace by the given name, if it's been previously registered
    ///
    /// - Parameter name: The name of the `Traceable` or `Trace` item to start
    /// - Returns: `nil` if the passed in trace isn't registered, otherwise returns
    ///            a tuple `TraceStarted` with signals that can be listened to for trace changes
    ///
    /// Note: this is a no-op if there's an active trace running
    @discardableResult
    public func startTrace(named name: String) -> TraceStarted? {
        // no-op if no trace registered by that name
        guard currentTraceRunner == nil, let trace = registeredTraces.first(where: { $0.name == name }) else {
            return nil
        }
        
        let traceRunner = TraceRunner(trace: trace)
        currentTraceRunner = traceRunner
        traceRunner.start()
        return TraceStarted(currentState: traceRunner.result.state, stateChanged: traceRunner.result.stateChanged, itemLogged: traceRunner.itemLogged)
    }
    
    /// Logs the given `TraceItem`; this is a no-op if no active trace is running
    ///
    /// - Parameter item: The `TraceItem` to log
    ///
    /// E.g. if you were tracing analytics calls, you'd fire this for events and user property
    ///      changes and it would log that and compare it to the current trace being run
    public func log(item: TraceItem) {
        currentTraceRunner?.itemLogged.fire(data: item)
    }
    
    /// Stops and clears the current trace
    ///
    /// - Returns: A `TraceReport`, if there was an active trace being run
    @discardableResult
    public func stopCurrentTrace() -> TraceReport? {
        guard let result = currentTraceRunner?.stop() else { return nil }
        currentTraceRunner = nil
        return TraceReport(result: result)
    }
    
    // MARK: - Private Properties
    
    fileprivate var registeredTraces = [Traceable]()
    fileprivate var currentTraceRunner: TraceRunner?
    
}
