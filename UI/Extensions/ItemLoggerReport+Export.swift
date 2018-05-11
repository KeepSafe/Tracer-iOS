//
//  ItemLoggerReport+Export.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

extension ItemLoggerReport {
    func exportedAsTextFile() -> URL? {
        let rawLogFilename = "allLoggedItems_\(Date().timeIntervalSince1970).txt"
        let rawLogFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(rawLogFilename)
        do {
            var report = self
            let rawLog = report.rawLog
            try rawLog.write(to: rawLogFilePath, atomically: true, encoding: .utf8)
            return rawLogFilePath
        } catch {
            return nil
        }
    }
}
