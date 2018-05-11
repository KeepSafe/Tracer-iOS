//
//  ItemLoggerReport.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A report of an item logger session
public struct ItemLoggerReport {
    
    /// Creates a report of an item logger session.
    ///
    /// - Parameter loggedItems: An array of logged items
    internal init(loggedItems: [LoggedItem]) {
        self.loggedItems = loggedItems
    }
    
    /// Generates a multi-line string representation of all
    /// items logged during during this session.
    public lazy var rawLog: String = {
        return generateRawLog()
    }()
    
    /// The array of `LoggedItem`s during this `ItemLogger` session
    /// (e.g. prior to this report being generated)
    public let loggedItems: [LoggedItem]
    
}

// MARK: - Private API

fileprivate extension ItemLoggerReport {
    
    mutating func generateRawLog() -> String {
        let itemDescriptions = loggedItems.map({ loggedItem -> String in
            return """
            \(loggedItem.item)
            ---> timestamp: \(TraceDateFormatter.default.string(from: loggedItem.timestamp)),
            ---> properties: \(loggedItem.properties?.loggerDescription ?? "none")
            """
        }).joined(separator: "\n\n")
        
        return """
        
        ========  Begin Item Logger Session  ========
        
        \(itemDescriptions)
        
        ========   End Item Logger Session   ========
        
        """
    }
    
}
