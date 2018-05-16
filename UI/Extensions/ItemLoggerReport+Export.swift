//
//  ItemLoggerReport+Export.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

extension ItemLoggerReport {
    func exportedAsCSVFile() -> URL? {
        let csvLogFilename = "allLoggedItems_\(Date().timeIntervalSince1970).csv"
        let csvLogFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(csvLogFilename)
        do {
            var report = self
            let csvLog = report.csvLog
            try csvLog.write(to: csvLogFilePath, atomically: true, encoding: .utf8)
            return csvLogFilePath
        } catch {
            return nil
        }
    }
}
