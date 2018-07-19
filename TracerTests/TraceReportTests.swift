//
//  TraceReportTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceReportTests: XCTestCase {

    private let ia = TraceItem(type: "item a", itemToMatch: AnyTraceEquatable("a"))
    private let ib = TraceItem(type: "item b", itemToMatch: AnyTraceEquatable("b"))
    private let ic = TraceItem(type: "item c", itemToMatch: AnyTraceEquatable("c"))
    private let id = TraceItem(type: "item d", itemToMatch: AnyTraceEquatable("d"))
    private let ie = TraceItem(type: "item e", itemToMatch: AnyTraceEquatable("e"))
    
    func testSummaryPassed() {
        let trace = Trace(name: "summaryLog",
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ia)
        result.handleFiring(of: ib)
        result.handleFiring(of: ic)
        result.handleFiring(of: id)
        result.handleFiring(of: ie)
        result.finalize()
        
        let report = TraceReport(result: result)
        let summaryLog = report.summary
        
        XCTAssertTrue(summaryLog.contains("Begin Trace Report"))
        XCTAssertTrue(summaryLog.contains("Trace name: summaryLog"))
        XCTAssertTrue(summaryLog.contains("Start time:"))
        XCTAssertTrue(summaryLog.contains("End time:"))
        XCTAssertTrue(summaryLog.contains("Result: passed"))
        XCTAssertTrue(summaryLog.contains("What does this mean?: \(TraceState.passed.debugDescription)"))
        XCTAssertTrue(summaryLog.contains("Enforcing order?: true"))
        XCTAssertTrue(summaryLog.contains("Allow duplicates?: true"))
        XCTAssertTrue(summaryLog.contains("Results Legend"))
        XCTAssertTrue(summaryLog.contains("Trace Results"))
        XCTAssertTrue(summaryLog.contains("Total items to match: 5"))
        XCTAssertTrue(summaryLog.contains("Matched: 5 out of 5"))
        XCTAssertTrue(summaryLog.contains("Missing: 0 out of 5"))
        XCTAssertTrue(summaryLog.contains("Out of order: 0 out of 5"))
        XCTAssertTrue(summaryLog.contains("Had Duplicates: 0 out of 5"))
        XCTAssertTrue(summaryLog.contains("Ignored, but matched: 0"))
        XCTAssertTrue(summaryLog.contains("Ignored, no match: 0"))
        XCTAssertTrue(summaryLog.contains("Items To Match Log"))
        XCTAssertTrue(summaryLog.contains("matched\n---> type: item a,\n     itemToMatch: a"))
        XCTAssertTrue(summaryLog.contains("matched\n---> type: item b,\n     itemToMatch: b"))
        XCTAssertTrue(summaryLog.contains("matched\n---> type: item c,\n     itemToMatch: c"))
        XCTAssertTrue(summaryLog.contains("matched\n---> type: item d,\n     itemToMatch: d"))
        XCTAssertTrue(summaryLog.contains("matched\n---> type: item e,\n     itemToMatch: e"))
        XCTAssertTrue(summaryLog.contains("Raw Log"))
        XCTAssertTrue(summaryLog.contains("The raw log can be exported separately"))
        XCTAssertTrue(summaryLog.contains("End Trace Report"))
    }
    
    func testSummaryFailedMissing() {
        let trace = Trace(name: "summaryLogMissing",
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ia)
        result.finalize()
        
        let report = TraceReport(result: result)
        let summaryLog = report.summary
        
        XCTAssertTrue(summaryLog.contains("Result: failed"))
        XCTAssertTrue(summaryLog.contains("Missing: 4 out of 5"))
    }
    
    func testSummaryFailedOrder() {
        let trace = Trace(name: "summaryLogOrder",
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ie)
        result.finalize()
        
        let report = TraceReport(result: result)
        let summaryLog = report.summary
        
        XCTAssertTrue(summaryLog.contains("Result: failed"))
        XCTAssertTrue(summaryLog.contains("Out of order: 5 out of 5"))
    }
    
    func testSummaryFailedDuplicate() {
        let trace = Trace(name: "summaryLogDuplicates",
                          allowDuplicates: false,
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ia)
        result.handleFiring(of: ia)
        result.finalize()
        
        let report = TraceReport(result: result)
        let summaryLog = report.summary
        
        XCTAssertTrue(summaryLog.contains("Result: failed"))
        XCTAssertTrue(summaryLog.contains("Had Duplicates: 1 out of 5"))
    }
    
    func testSummaryFailedIgnored() {
        let trace = Trace(name: "summaryLogIgnored",
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ia)
        result.handleFiring(of: ia)
        result.handleFiring(of: ia)
        result.handleFiring(of: TraceItem(type: "ignoreMe", itemToMatch: AnyTraceEquatable("ignored")))
        result.finalize()
        
        let report = TraceReport(result: result)
        let summaryLog = report.summary
        
        XCTAssertTrue(summaryLog.contains("Result: failed"))
        XCTAssertTrue(summaryLog.contains("Ignored, but matched: 2"))
        XCTAssertTrue(summaryLog.contains("Ignored, no match: 1"))
    }
    
    func testRawLog() {
        let trace = Trace(name: "rawLog",
                          itemsToMatch: [ia, ib, ic, id, ie])
        
        let result = TraceResult(trace: trace)
        result.handleFiring(of: ia)
        result.handleFiring(of: ib)
        result.handleFiring(of: ic)
        result.handleFiring(of: id)
        result.handleFiring(of: ie)
        result.handleFiring(of: ia)
        result.handleFiring(of: ib)
        result.finalize()
        
        let report = TraceReport(result: result)
        let rawLog = report.rawLog
        
        XCTAssertTrue(rawLog.contains("Begin Trace Raw Log"))
        XCTAssertTrue(rawLog.contains("Trace name: rawLog"))
        XCTAssertTrue(rawLog.contains("Start time:"))
        XCTAssertTrue(rawLog.contains("End time:"))
        XCTAssertTrue(rawLog.contains("matched\n---> type: item a,\n     itemToMatch: a"))
        XCTAssertTrue(rawLog.contains("matched\n---> type: item b,\n     itemToMatch: b"))
        XCTAssertTrue(rawLog.contains("matched\n---> type: item c,\n     itemToMatch: c"))
        XCTAssertTrue(rawLog.contains("matched\n---> type: item d,\n     itemToMatch: d"))
        XCTAssertTrue(rawLog.contains("matched\n---> type: item e,\n     itemToMatch: e"))
        XCTAssertTrue(rawLog.contains("ignoredButMatched\n---> type: item a,\n     itemToMatch: a"))
        XCTAssertTrue(rawLog.contains("ignoredButMatched\n---> type: item b,\n     itemToMatch: b"))
        XCTAssertTrue(rawLog.contains("End Trace Raw Log"))
    }
    
}
