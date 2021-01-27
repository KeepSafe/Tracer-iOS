////
////  TraceItem.swift
////  Tracer
////
////  Created by Rob Phillips on 4/27/18.
////  Copyright © 2018 Keepsafe Inc. All rights reserved.
////

import Foundation

/// An individual item used within a `Trace` or `Traceable` execution.
public struct TraceItem {
    /// Creates an individual item used within a `Trace` or `Traceable` execution
    ///
    /// - Parameters:
    ///   - type: A display string representing the type of item, such as `Event` or `User Properties`
    ///   - itemToMatch: An item to match against, conforming to `Equatable` so it can be boxed in `AnyTraceEquatable`
    ///   - uxFlowHint: An optional hint to display for what action to take in the UI/UX to emit the `itemToMatch` (e.g. "Tap the sign up button")
    public init(type: String, itemToMatch: AnyTraceEquatable, uxFlowHint: String? = nil) {
        self.type = type
        self.itemToMatch = itemToMatch
        self.uxFlowHint = uxFlowHint
    }

    /// A display string representing the type of item, such as `Event` or `User Properties`
    public let type: String
    
    /// An item to match against, conforming to `Equatable` so it can be boxed in `AnyTraceEquatable`
    public let itemToMatch: AnyTraceEquatable
    
    /// An optional hint to display for what action to take in the UI/UX to emit the `itemToMatch`
    /// e.g. "Tap the sign up button"
    public let uxFlowHint: String?
}

extension TraceItem: Equatable {
    public static func == (lhs: TraceItem, rhs: TraceItem) -> Bool {
        return lhs.type == rhs.type &&
               lhs.itemToMatch == rhs.itemToMatch
    }
}

extension TraceItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        if itemToMatch is TextOutputStreamable {
            hasher.combine(type)
            return
        }

        hasher.combine(type)
        hasher.combine(String(describing: itemToMatch))
    }
}
