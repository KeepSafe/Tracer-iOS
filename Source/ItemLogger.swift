//
//  ItemLogger.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A signal that is fired any time an item was logged
public typealias ItemLoggedSignal = TraceSignal<AnyTraceEquatable>

/// Main interface for generic item logger
/// (e.g. useful for logging items outside of running races)
public final class ItemLogger {
    
    // MARK: - Instantiation
    
    /// Instantiation point for a logger
    public init() {}
    
    // MARK: - API
    
    /// Starts listening for items to be logged
    ///
    /// - Returns: An `ItemLoggedSignal` that can be listened to for items that were logged
    @discardableResult
    public func start() -> ItemLoggedSignal {
        guard listener == nil else {
            // Logger already active
            return itemLogged
        }
        
        listener = itemLogged.listen(wasFired: { [weak self] item in
            self?.loggedItems.append(LoggedItem(item))
        })
        return itemLogged
    }
    
    /// Logs the given `AnyTraceEquatable` item
    /// (e.g. any item that is boxed in any `AnyTraceEquatable` like `AnyTraceEquatable("Hello")`)
    /// this is a no-op if no active trace is running
    ///
    /// - Parameter item: The `AnyTraceEquatable` to log
    ///
    /// E.g. if you were logging analytics calls, you'd fire this for events and user property
    ///      changes and it would log that in memory until you asked it to stop
    public func log(item: AnyTraceEquatable) {
        itemLogged.fire(data: item)
    }
    
    /// Stops the current logging session, removes all listeners, and returns all logged items during that session
    ///
    /// - Returns: An array `LoggedItem`s during this session
    @discardableResult
    public func stop() -> [LoggedItem] {
        if let listener = listener {
            itemLogged.remove(listener: listener)
        }
        return loggedItems
    }
    
    /// Removes all logged items from this session
    public func clear() {
        loggedItems.removeAll()
    }
    
    // MARK: - Internal Properties
    
    fileprivate(set) var loggedItems = [LoggedItem]()
    
    // MARK: - Private Properties

    fileprivate var listener: TraceSignalListener?
    fileprivate let itemLogged = ItemLoggedSignal()
    
}
