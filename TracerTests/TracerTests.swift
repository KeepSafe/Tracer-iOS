//
//  TracerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/2/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TracerTests: XCTestCase {

    let testTraceItem = TraceItem(type: "testing", itemToMatch: AnyTraceEquatable(true))
    
    func testRegisteringTrace() {
        let tracer = Tracer()
        let trace = Trace(name: "register", itemsToMatch: [testTraceItem])
        XCTAssertTrue(tracer.register(trace: trace))
        // Trying to register it again should be a no-op
        XCTAssertFalse(tracer.register(trace: trace))
    }
    
    func testStartingTraceByName() {
        let tracer = Tracer()
        let trace = Trace(name: "start", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)
        XCTAssertNotNil(tracer.startTrace(named: "start"))
    }
    
    func testStartingTraceWithoutRegisteringIt() {
        let tracer = Tracer()
        XCTAssertNil(tracer.startTrace(named: "doesntExistYet"))
    }
    
    func testStartingTraceAfterRegisteringIt() {
        let tracer = Tracer()
        let trace = Trace(name: "start", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)
        XCTAssertNotNil(tracer.start(trace: trace))
        
        // If we try to start it again, it should be a no-op
        XCTAssertNil(tracer.startTrace(named: "start"))
    }
    
    func testStartingTraceSignalsSuccess() {
        let tracer = Tracer()
        let trace = Trace(name: "passing_signals", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)

        let (currentState, stateChanged, itemLogged) = tracer.start(trace: trace)!
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
        tracer.stopCurrentTrace()
        wait(for: [tracePassed], timeout: 5)
    }
    
    func testStartingTraceSignalsFailure() {
        let tracer = Tracer()
        let trace = Trace(name: "failing_signal", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)
        
        let (currentState, stateChanged, _) = tracer.start(trace: trace)!
        XCTAssertTrue(currentState == .waiting)
        
        let traceFailing = expectation(description: "traceFailing")
        stateChanged.listen { traceState in
            XCTAssertTrue(traceState == .failed)
            traceFailing.fulfill()
        }
        // finalize test results which will mark `testTraceItem` as missing
        tracer.stopCurrentTrace()
        wait(for: [traceFailing], timeout: 5)
    }
    
    func testLoggingItemToTrace() {
        let tracer = Tracer()
        let trace = Trace(name: "logItem", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)
        
        let (currentState, _, itemLogged) = tracer.start(trace: trace)!
        XCTAssertTrue(currentState == .waiting)
        
        let itemWasLogged = expectation(description: "itemWasLogged")
        itemLogged.listen { loggedItem in
            XCTAssertTrue(loggedItem == self.testTraceItem)
            itemWasLogged.fulfill()
        }
        tracer.log(item: testTraceItem)
        wait(for: [itemWasLogged], timeout: 5)
        
        // Check the trace results to see what was logged
        let report = tracer.stopCurrentTrace()
        XCTAssertTrue(report?.result.state == .passed)
        let loggedItem = report?.result.statesForItemsToMatch.first
        XCTAssertTrue(loggedItem?.keys.first == testTraceItem)
        XCTAssertTrue(loggedItem?.values.first == .matched)
    }
    
    func testStoppingTrace() {
        let tracer = Tracer()
        let trace = Trace(name: "stop", itemsToMatch: [testTraceItem])
        tracer.register(trace: trace)
        tracer.start(trace: trace)
        
        // Generates a report
        XCTAssertNotNil(tracer.stopCurrentTrace())
        
        // But is a no-op if no trace is running
        XCTAssertNil(tracer.stopCurrentTrace())
    }
    
}
