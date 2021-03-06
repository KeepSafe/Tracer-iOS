//
//  TraceTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceTests: XCTestCase {
    
    private let testTraceItem = TraceItem(type: "traceTests", itemToMatch: AnyTraceEquatable(true))

    func testInstantiationDefaultProperties() {
        let trace = Trace(name: "foo", itemsToMatch: [testTraceItem])
        XCTAssertTrue(trace.name == "foo")
        XCTAssertTrue(trace.enforceOrder == true)
        XCTAssertTrue(trace.allowDuplicates == true)
        XCTAssertTrue(trace.assertOnFailure == false)
    }
    
    func testInstantiationCustomProperties() {
        let setupExp = expectation(description: "setupCalled")
        let trace = Trace(name: "hai", enforceOrder: false, allowDuplicates: false, assertOnFailure: true, itemsToMatch: [testTraceItem], setupSteps: ["Don't panic"], setupBeforeStartingTrace: {
            setupExp.fulfill()
        })
        
        XCTAssertTrue(trace.name == "hai")
        XCTAssertTrue(trace.enforceOrder == false)
        XCTAssertTrue(trace.allowDuplicates == false)
        XCTAssertTrue(trace.assertOnFailure == true)
        XCTAssertTrue(trace.itemsToMatch.count == 1)
        XCTAssertTrue(trace.itemsToMatch.first == testTraceItem)
        XCTAssertTrue(trace.setupSteps?.count == 1)
        XCTAssertTrue(trace.setupSteps?.first == "Don't panic")
        XCTAssertNotNil(trace.setupBeforeStartingTrace)
        trace.setupBeforeStartingTrace?()
        wait(for: [setupExp], timeout: 5)
    }
    
    func testSetupStepsList() {
        let trace = Trace(name: "backToTheFuture",
                          itemsToMatch: [testTraceItem],
                          setupSteps: ["Turn on flux capacitor",
                                       "Set desired date in time",
                                       "Buckle up, buttercup"])
        let setupList = trace.setupStepsAsList!
        XCTAssertTrue(setupList.contains("Setup steps:\n\n"))
        XCTAssertTrue(setupList.contains("1. Turn on flux capacitor\n"))
        XCTAssertTrue(setupList.contains("2. Set desired date in time\n"))
        XCTAssertTrue(setupList.contains("3. Buckle up, buttercup\n"))
    }
    
    func testEquality() {
        let ti0 = TraceItem(type: "ti0", itemToMatch: AnyTraceEquatable(true))
        let ti1 = TraceItem(type: "ti2", itemToMatch: AnyTraceEquatable(false))
        
        let t0 = Trace(name: "equal1", itemsToMatch: [ti0])
        let t1 = Trace(name: "equal1", itemsToMatch: [ti0])
        let t2 = Trace(name: "equal1", itemsToMatch: [ti1])
        let t3 = Trace(name: "equal2", itemsToMatch: [ti0])

        // Equal if names are equal
        XCTAssertTrue(t0 == t1)
        XCTAssertTrue(t1 != t3)
        XCTAssertTrue(t2 != t3)

        // Items to match doesn't matter
        XCTAssertTrue(t0 == t2)
    }
    
}
