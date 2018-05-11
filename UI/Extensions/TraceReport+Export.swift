//
//  TraceReport+Export.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

extension TraceReport {
    func exportedAsTextFiles() -> (summary: URL, rawLog: URL)? {
        guard let name = result.trace.name.replacingOccurrences(of: " ", with: "_").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        let executionDate = result.startTime.timeIntervalSince1970
        let summaryFilename = "traceSummary_\(name)_\(executionDate).txt"
        let rawLogFilename = "traceRawLog_\(name)_\(executionDate).txt"
        let summaryFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(summaryFilename)
        let rawLogFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(rawLogFilename)
        do {
            var report = self
            let summary = report.summary
            let rawLog = report.rawLog
            try summary.write(to: summaryFilePath, atomically: true, encoding: .utf8)
            try rawLog.write(to: rawLogFilePath, atomically: true, encoding: .utf8)
            return (summaryFilePath, rawLogFilePath)
        } catch {
            return nil
        }
    }
}
