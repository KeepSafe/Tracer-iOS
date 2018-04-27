////
////  TraceItem.swift
////  Tracer
////
////  Created by Rob Phillips on 4/27/18.
////  Copyright © 2018 Keepsafe Inc. All rights reserved.
////

import Foundation

/// An individual item within a `Trace` or `Traceable` execution.
public struct TraceItem {
    /// A display string representing the type of item, such as `Event` or `User Properties`
    public var type: String
    
    /// An item to match against, conforming to `Equatable` so it can be boxed in `AnyTraceEquatable`
    public var itemToMatch: AnyTraceEquatable
    
    /// An optional hint to display for what action to take in the UI/UX to emit the `itemToMatch`
    /// e.g. "Tap the sign up button"
    public var uxFlowHint: String?
}

extension TraceItem: Equatable {
    public static func == (lhs: TraceItem, rhs: TraceItem) -> Bool {
        return lhs.type == rhs.type &&
               lhs.itemToMatch == rhs.itemToMatch
    }
}
