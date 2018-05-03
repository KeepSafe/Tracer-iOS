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
    
    /// Whether or not to allow duplicates of the `itemsToMatch` to be ignored once they've been matched
    var allowDuplicates: Bool { get }
    
    /// Whether or not to assert when the trace's state changes to `failed`
    var assertOnFailure: Bool { get }
    
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
    ///   - enforceOrder: Whether or not to enforce the emitted order of elements in `itemsToMatch`; defaults to true
    ///   - allowDuplicates: Whether or not to allow duplicates of the `itemsToMatch` to be ignored once they've been matched; defaults to true
    ///   - assertOnFailure: Whether or not to assert when the trace's state changes to `failed`
    ///   - itemsToMatch: An array of `TraceItem`'s to match against during an active trace
    ///   - setupSteps: An optional array of setup steps rendered as a numbered list
    ///   - setupBeforeStartingTrace: An optional closure to execute arbitrary setup steps before the
    ///                               trace is run such as setting up any application state
    public init(name: String,
                enforceOrder: Bool = true,
                allowDuplicates: Bool = true,
                assertOnFailure: Bool = false,
                itemsToMatch: [TraceItem],
                setupSteps: [String]? = nil,
                setupBeforeStartingTrace: TracerSetupClosure? = nil) {
        self.name = name
        self.enforceOrder = enforceOrder
        self.allowDuplicates = allowDuplicates
        self.assertOnFailure = assertOnFailure
        self.itemsToMatch = itemsToMatch
        self.setupSteps = setupSteps
        self.setupBeforeStartingTrace = setupBeforeStartingTrace
    }
    
    /// The display name of the trace (e.g. `Sign up flow`)
    public let name: String
    
    /// Whether or not to enforce the emitted order of elements in `itemsToMatch`; defaults to `true`
    public let enforceOrder: Bool
    
    /// Whether or not to allow duplicates of the `itemsToMatch` to be ignored once they've been matched; defaults to `true`
    public let allowDuplicates: Bool
    
    /// Whether or not to assert when the trace's state changes to `failed`
    public let assertOnFailure: Bool
    
    /// An array of `TraceItem`'s to match against during an active trace
    public let itemsToMatch: [TraceItem]
    
    /// An optional array of setup steps rendered as a numbered list (i.e. pass these in without numbers)
    public let setupSteps: [String]?
    
    /// Returns a numbered of list of the setup steps
    public var setupStepsAsList: String? {
        guard let setupSteps = setupSteps, setupSteps.isEmpty == false else { return nil }
        var numberedList = "Setup steps:\n\n"
        for (index, step) in setupSteps.enumerated() {
            numberedList.append("    \(index + 1). \(step)\n")
        }
        return numberedList
    }
    
    /// An optional closure to execute arbitrary setup steps before the
    /// trace is run such as setting up any application state
    public let setupBeforeStartingTrace: TracerSetupClosure?
}
