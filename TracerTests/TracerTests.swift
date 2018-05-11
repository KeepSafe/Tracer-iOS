//
//  TracerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TracerTests: XCTestCase {

    private let testTraceItem = TraceItem(type: "TracerTests", itemToMatch: AnyTraceEquatable(true))
    
    func testInstantiation() {
        let trace = Trace(name: "instantiation", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        XCTAssertTrue(tracer.result.statesForItemsToMatch.first?.keys.first == testTraceItem)
    }
    
    func testIsRunning() {
        let trace = Trace(name: "startRunning", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        
        XCTAssertFalse(tracer.isRunning)
        tracer.start()
        XCTAssertTrue(tracer.isRunning)
        tracer.stop()
        XCTAssertFalse(tracer.isRunning)
    }
    
    func testStartCallsSetup() {
        let setupExp = expectation(description: "setupCalled")
        let trace = Trace(name: "startSetup", itemsToMatch: [testTraceItem], setupBeforeStartingTrace: {
            setupExp.fulfill()
        })
        Tracer(trace: trace).start()
        wait(for: [setupExp], timeout: 5)
    }
    
    func testStartListensForItemsToLog() {
        let trace = Trace(name: "startSignals", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        
        // Try to fire a signal before starting and see if anything is logged
        tracer.log(item: testTraceItem)
        XCTAssertNil(tracer.result.statesForAllLoggedItems.first?.keys.first)
        
        // Now start it and do the same
        tracer.start()
        tracer.log(item: testTraceItem)
        XCTAssertTrue(tracer.result.statesForAllLoggedItems.first?.keys.first == testTraceItem)
    }
    
    func testStopRemovesListener() {
        let trace = Trace(name: "stopSignals", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        tracer.start()
        
        // Now stop and see if the item gets logged
        _ = tracer.stop()
        tracer.log(item: testTraceItem)
        XCTAssertNil(tracer.result.statesForAllLoggedItems.first?.keys.first)
    }
    
    func testStopReturnsFinalizedResult() {
        let trace = Trace(name: "stopResults", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        tracer.start()
        tracer.log(item: testTraceItem)
        
        var report = tracer.stop()
        XCTAssertNotNil(report) // Generates a report
        XCTAssertTrue(report.result.state == .passed)
        
        // But will just return the same report again if called again
        var report2 = tracer.stop()
        XCTAssertTrue(report.summary == report2.summary)
    }
    
    func testStartingTraceSignalsSuccess() {
        let trace = Trace(name: "passing_signals", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        
        let (currentState, stateChanged, itemLogged) = tracer.start()
        XCTAssertTrue(currentState == .waiting)
        
        let tracePassing = expectation(description: "tracePassing")
        stateChanged.listen { traceState in
            XCTAssertTrue(traceState == .passing)
            tracePassing.fulfill()
            stateChanged.removeAllListeners()
        }
        let itemWasLogged = expectation(description: "itemWasLogged")
        itemLogged.listen { loggedItem in
            XCTAssertTrue(loggedItem == self.testTraceItem)
            itemWasLogged.fulfill()
        }
        tracer.log(item: testTraceItem)
        wait(for: [tracePassing, itemWasLogged], timeout: 5)
        
        let tracePassed = expectation(description: "tracePassed")
        stateChanged.listen { traceState in
            XCTAssertTrue(traceState == .passed)
            tracePassed.fulfill()
        }
        tracer.stop()
        wait(for: [tracePassed], timeout: 5)
    }
    
    func testStartingTraceSignalsFailure() {
        let trace = Trace(name: "failing_signal", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        
        let (currentState, stateChanged, _) = tracer.start()
        XCTAssertTrue(currentState == .waiting)
        
        let traceFailing = expectation(description: "traceFailing")
        stateChanged.listen { traceState in
            XCTAssertTrue(traceState == .failed)
            traceFailing.fulfill()
        }
        // finalize test results which will mark `testTraceItem` as missing
        tracer.stop()
        wait(for: [traceFailing], timeout: 5)
    }
    
    func testLoggingItemToTrace() {
        let trace = Trace(name: "logItem", itemsToMatch: [testTraceItem])
        let tracer = Tracer(trace: trace)
        
        let (currentState, _, itemLogged) = tracer.start()
        XCTAssertTrue(currentState == .waiting)
        
        let itemWasLogged = expectation(description: "itemWasLogged")
        itemLogged.listen { loggedItem in
            XCTAssertTrue(loggedItem == self.testTraceItem)
            itemWasLogged.fulfill()
        }
        tracer.log(item: testTraceItem)
        wait(for: [itemWasLogged], timeout: 5)
        
        // Check the trace results to see what was logged
        let report = tracer.stop()
        XCTAssertTrue(report.result.state == .passed)
        let loggedItem = report.result.statesForItemsToMatch.first
        XCTAssertTrue(loggedItem?.keys.first == testTraceItem)
        XCTAssertTrue(loggedItem?.values.first == .matched)
    }
    
}
