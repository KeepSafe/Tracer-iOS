//
//  Trace.swift
//  Tracer
//
//  Created by Rob Phillips on 4/27/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

public typealias TracerSetupClosure = () -> ()

/// Protocol for creating your own `Traceable` list items
public protocol Traceable {
    /// The display name of the trace (e.g. `Sign up flow`)
    var name: String { get }
    
    /// Whether or not to enforce the emitted order of elements in `itemsToMatch`
    var enforceOrder: Bool { get }
    
    /// An array of `TraceItem`'s to match against during an active trace
    var itemsToMatch: [TraceItem] { get }
    
    /// An optional array of setup steps rendered as a numbered list
    var setupSteps: [String]? { get }
    
    /// An optional closure to execute arbitrary setup steps before the
    /// trace is run such as setting up any application state
    var setupBeforeStartingTrace: TracerSetupClosure? { get }
}

/// A trace that can be executed and scored for.
public struct Trace: Traceable {
    /// Creates a trace that can be executed and scored for.
    ///
    /// - Parameters:
    ///   - name: The display name of the trace (e.g. `Sign up flow`)
    ///   - enforceOrder: Whether or not to enforce the emitted order of elements in `itemsToMatch`
    ///   - itemsToMatch: An array of `TraceItem`'s to match against during an active trace
    ///   - setupSteps: An optional array of setup steps rendered as a numbered list
    ///   - setupBeforeStartingTrace: An optional closure to execute arbitrary setup steps before the
    ///                               trace is run such as setting up any application state
    public init(name: String,
                enforceOrder: Bool = true,
                itemsToMatch: [TraceItem],
                setupSteps: [String]? = nil,
                setupBeforeStartingTrace: TracerSetupClosure? = nil) {
        self.name = name
        self.enforceOrder = enforceOrder
        self.itemsToMatch = itemsToMatch
        self.setupSteps = setupSteps
        self.setupBeforeStartingTrace = setupBeforeStartingTrace
    }
    
    public let name: String
    public let enforceOrder: Bool
    public let itemsToMatch: [TraceItem]
    public let setupSteps: [String]?
    public let setupBeforeStartingTrace: TracerSetupClosure?
}
