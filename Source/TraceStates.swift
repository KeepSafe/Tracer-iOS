//
//  TraceStates.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// The state of an active trace
public enum TraceState: String, CustomDebugStringConvertible {
    /// We are waiting for our first traceable item to be emitted
    case waiting
    
    /// This trace is passing so far, but the trace isn't completed yet
    case passing
    
    /// The trace has completed and all trace items were accounted for
    case passed
    
    /// This trace has failed in some way; check its report for more information
    case failed
    
    public var debugDescription: String {
        switch self {
        case .waiting: return "We are waiting for our first traceable item to be emitted"
        case .passing: return "This trace is passing so far, but the trace isn't completed yet"
        case .passed: return "The trace has completed and all trace items were accounted for"
        case .failed: return "This trace has failed in some way; check its report for more information"
        }
    }
}

/// The state of a items within an active trace
public enum TraceItemState: String, CustomDebugStringConvertible {
    /// The trace is running and this item is still waiting to be matched
    case waitingToBeMatched
    
    /// This trace item was fired (and fired in the right order if the trace was enforcing order)
    case matched
    
    /// This trace was enforcing order and this item was fired out-of-order
    case outOfOrder
    
    /// The trace has completed and this trace item was unaccounted for
    case missing
    
    /// Did not find this item in the trace's `itemsToMatch`, so it was ignored
    case ignoredNoMatch
    
    /// This matched an item in the trace's `itemsToMatch` but we had already matched all necessary items of that type, so it was ignored
    case ignoredButMatched
    
    /// This was a duplicate of an item in the trace's `itemsToMatch` that we already matched all of and this trace was enforcing no duplicates, so it failed
    case duplicate
    
    /// A duplicate of this item was fired after it and this trace was enforcing no duplicates, so it failed
    case hadDuplicates
    
    // MARK: - Description
    
    /// Debug descriptions useful in summary reports to help others understand each state's meaning
    public var debugDescription: String {
        switch self {
        case .waitingToBeMatched: return "The trace is running and this item is still waiting to be matched"
        case .matched: return "This trace item was fired (and fired in the right order if the trace was enforcing order)"
        case .outOfOrder: return "This trace was enforcing order and this item was fired out-of-order"
        case .missing: return "The trace has completed and this trace item was unaccounted for"
        case .ignoredNoMatch: return "Did not find this item in the trace's `itemsToMatch`, so it was ignored"
        case .ignoredButMatched: return "This matched an item in the trace's `itemsToMatch` but we had already matched all necessary items of that type, so it was ignored"
        case .duplicate: return "This was a duplicate of an item in the trace's `itemsToMatch` that we already matched all of and this trace was enforcing no duplicates, so it failed"
        case .hadDuplicates: return "A duplicate of this item was fired after it and this trace was enforcing no duplicates, so it failed"
        }
    }
}
