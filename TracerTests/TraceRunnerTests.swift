//
//  TraceRunnerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceRunnerTests: XCTestCase {

    private let testTraceItem = TraceItem(type: "traceRunnerTests", itemToMatch: AnyTraceEquatable(true))
    
    func testInstantiation() {
        let trace = Trace(name: "instantiation", itemsToMatch: [testTraceItem])
        let runner = TraceRunner(trace: trace)
        XCTAssertTrue(runner.result.statesForItemsToMatch.first?.keys.first == testTraceItem)
    }
    
    func testStartCallsSetup() {
        let setupExp = expectation(description: "setupCalled")
        let trace = Trace(name: "startSetup", itemsToMatch: [testTraceItem], setupBeforeStartingTrace: {
            setupExp.fulfill()
        })
        TraceRunner(trace: trace).start()
        wait(for: [setupExp], timeout: 5)
    }
    
    func testStartListensForItemsToLog() {
        let trace = Trace(name: "startSignals", itemsToMatch: [testTraceItem])
        let runner = TraceRunner(trace: trace)
        
        // Try to fire a signal before starting and see if anything is logged
        runner.itemLogged.fire(data: testTraceItem)
        XCTAssertNil(runner.result.statesForAllLoggedItems.first?.keys.first)
        
        // Now start it and do the same
        runner.start()
        runner.itemLogged.fire(data: testTraceItem)
        XCTAssertTrue(runner.result.statesForAllLoggedItems.first?.keys.first == testTraceItem)
    }
    
    func testStopRemovesListener() {
        let trace = Trace(name: "stopSignals", itemsToMatch: [testTraceItem])
        let runner = TraceRunner(trace: trace)
        runner.start()
        
        // Now stop and see if the item gets logged
        _ = runner.stop()
        runner.itemLogged.fire(data: testTraceItem)
        XCTAssertNil(runner.result.statesForAllLoggedItems.first?.keys.first)
    }
    
    func testStopReturnsFinalizedResult() {
        let trace = Trace(name: "stopResults", itemsToMatch: [testTraceItem])
        let runner = TraceRunner(trace: trace)
        runner.start()
        runner.itemLogged.fire(data: testTraceItem)
        
        let result = runner.stop()
        XCTAssertTrue(result.state == .passed)
    }
    
}
