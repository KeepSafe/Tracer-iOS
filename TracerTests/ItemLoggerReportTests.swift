//
//  ItemLoggerReportTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/21/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class ItemLoggerReportTests: XCTestCase {
    
    private let lia = LoggedItem(item: AnyTraceEquatable("a"), properties: ["test": AnyTraceEquatable("hai")])
    private let lib = LoggedItem(item: AnyTraceEquatable("b"))
    private let lic = LoggedItem(item: AnyTraceEquatable("c"))
    
    func testRawLog() {
        var report = ItemLoggerReport(loggedItems: [lia, lib, lic])
        let rawLog = report.rawLog
        debugPrint(rawLog)
        XCTAssertTrue(rawLog.contains("\n========  Begin Item Logger Session  ========\n\na\n---> timestamp: "))
        XCTAssertTrue(rawLog.contains(",\n---> properties: test: hai\n\n\nb\n---> timestamp: "))
        XCTAssertTrue(rawLog.contains(",\n---> properties: none\n\nc\n---> timestamp: "))
        XCTAssertTrue(rawLog.contains(",\n---> properties: none\n\n========   End Item Logger Session   ========\n"))
    }
    
    func testCSVLog() {
        var report = ItemLoggerReport(loggedItems: [lic, lib, lia])
        let csvLog = report.csvLog
        XCTAssertTrue(csvLog.contains("Item,Timestamp,Properties\r\nc,"))
        XCTAssertTrue(csvLog.contains(",none\r\nb,"))
        XCTAssertTrue(csvLog.contains(",none\r\na,"))
        XCTAssertTrue(csvLog.contains(",test: hai\r\n"))
    }
    
}
