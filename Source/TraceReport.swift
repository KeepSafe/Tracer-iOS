//
//  TraceReport.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// A report of a trace's execution
public struct TraceReport {
    /// Creates a report of the trace's execution
    ///
    /// - Parameter result: The result of the trace
    internal init(result: TraceResult) {
        self.result = result
    }
    
    /// A multi-line summary of the trace execution which can
    /// be displayed or otherwise exported to share with others.
    public lazy var summary: String = {
        return generateSummary()
    }()
    
    /// The original `TraceResult` from which this summary was generated
    /// in case you'd like to generate a custom report
    public let result: TraceResult
}

// MARK: - Private API

fileprivate extension TraceReport {
    
    func generateSummary() -> String {
        return "Soon... soon."
    }
    
}
