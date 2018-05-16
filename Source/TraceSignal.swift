//
//  TraceSignal.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A generic wrapper around a type that acts as a de-coupled signal<>listener
public final class TraceSignal<T> {
    
    // MARK: - API
    
    /// Listens for when this signal is fired and calls the passed in closure
    ///
    /// - Parameter wasFired: A closure that is called when this signal fires
    /// - Returns: A `TraceSignalListener` you can use to unregister with later
    @discardableResult
    public func listen(wasFired handler: @escaping (T) -> ()) -> TraceSignalListener {
        let listener = TraceSignalDispatcher(handler: handler)
        listeners[listener.id] = listener
        return listener
    }
    
    /// Fires this signal with the provided information
    ///
    /// - Parameter data: The generic data or information to emit with this signal
    public func fire(data: T) {
        for (_, listener) in listeners {
            listener.dispatch(data: data)
        }
    }
    
    /// Removes the given listener
    public func remove(listener: TraceSignalListener) {
        listeners.removeValue(forKey: listener.id)
    }
    
    // MARK: - Internal API
    
    /// Removes all listeners (only do this if you really know that no one else is listening)
    internal func removeAllListeners() {
        listeners.removeAll()
    }
    
    // MARK: - Private Properties
    
    private var listeners = [String: TraceSignalDispatcher<T>]()
    
}

/// Listener that is registered and can be used to remove independent listeners
public class TraceSignalListener {
    internal init() {}
    
    /// The identifier of this listener, used to unregister it
    public let id: String = NSUUID().uuidString.lowercased()
}

// MARK: - Private Classes

fileprivate final class TraceSignalDispatcher<T>: TraceSignalListener {
    init(handler: @escaping (T) -> ()) {
        self.handler = handler
        super.init()
    }
    
    func dispatch(data: T) {
        handler(data)
    }
    
    private let handler: (T) -> ()
}
