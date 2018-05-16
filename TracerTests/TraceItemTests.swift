//
//  TraceItemTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceItemTests: XCTestCase {
    
    func testInstantiationProperties() {
        let hint = "Whatever you do, don't press the red button"
        let ti = TraceItem(type: "instantiation", itemToMatch: AnyTraceEquatable(true), uxFlowHint: hint)
        XCTAssertTrue(ti.type == "instantiation")
        XCTAssertTrue(ti.itemToMatch == AnyTraceEquatable(true))
        XCTAssertTrue(ti.uxFlowHint == hint)
    }

    func testEquality() {
        let t0 = TraceItem(type: "equal1", itemToMatch: AnyTraceEquatable(true))
        let t1 = TraceItem(type: "equal1", itemToMatch: AnyTraceEquatable(true))
        let t2 = TraceItem(type: "equal2", itemToMatch: AnyTraceEquatable(true))
        let t3 = TraceItem(type: "equal1", itemToMatch: AnyTraceEquatable(false))
        let t4 = TraceItem(type: "equal1", itemToMatch: AnyTraceEquatable(true), uxFlowHint: "Swipe in the z dimension")
        
        // Equal if type and itemToMatch are equal
        XCTAssertTrue(t0 == t1)
        XCTAssertTrue(t1 != t2)
        XCTAssertTrue(t1 != t3)
        
        // UX flow hint doesn't matter
        XCTAssertTrue(t1 == t4)
    }
    
}
