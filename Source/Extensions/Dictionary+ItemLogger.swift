//
//  Dictionary+ItemLogger.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// Specifically, this is an extension of LoggedItemProperties which is typed as [String: AnyTraceEquatable]
internal extension Dictionary where Key: ExpressibleByStringLiteral, Value: CustomStringConvertible {
    
    var loggerDescription: String {
        var v = ""
        for (key, value) in self {
            v += ("\(key)" + ": \(value)\n")
        }
        return v
    }
    
    var csvDescription: String {
        return loggerDescription.cleanedForCSV()
    }
    
}
