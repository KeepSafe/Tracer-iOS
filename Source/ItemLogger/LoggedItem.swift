//
//  LoggedItem.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public typealias LoggedItemProperties = [String: AnyTraceEquatable]

/// An item that was logged during a logger session
public struct LoggedItem {
    /// Creates a logged item
    ///
    /// - Parameters:
    ///   - item: The `AnyTraceEquatable` item that was logged
    ///   - properties: An optional dictionary of properties logged along with this item
    internal init(item: AnyTraceEquatable, properties: LoggedItemProperties? = nil) {
        self.item = item
        self.properties = properties
    }
    
    /// The time at which this item was logged
    public let timestamp = Date()
    
    /// The `AnyTraceEquatable` item that was logged
    public let item: AnyTraceEquatable
    
    /// An optional dictionary of properties logged along with this item
    public let properties: LoggedItemProperties?
}
