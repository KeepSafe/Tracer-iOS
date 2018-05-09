//
//  ItemLoggerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class ItemLoggerTests: XCTestCase {
    
    func testInstantiationProperties() {
        let logger = ItemLogger()
        XCTAssertTrue(logger.loggedItems.isEmpty)
    }
    
    func testStartingAndLogging() {
        let logger = ItemLogger()
        let signal = logger.start()
        XCTAssertNotNil(signal)
        logger.log(item: AnyTraceEquatable(1))
        XCTAssertTrue(logger.loggedItems.count == 1)
        XCTAssertTrue(logger.loggedItems.first?.item == AnyTraceEquatable(1))
    }
    
    func testStartingWhileRunningDoesNothing() {
        let logger = ItemLogger()
        logger.start()
        logger.log(item: AnyTraceEquatable(1))
        XCTAssertTrue(logger.loggedItems.count == 1)
        logger.start()
        logger.log(item: AnyTraceEquatable(2))
        XCTAssertTrue(logger.loggedItems.count == 2)
        XCTAssertTrue(logger.loggedItems.last?.item == AnyTraceEquatable(2))
    }
    
    func testStoppingStopsLogging() {
        let logger = ItemLogger()
        logger.start()
        logger.log(item: AnyTraceEquatable(1))
        XCTAssertTrue(logger.loggedItems.count == 1)
        let loggedItems = logger.stop()
        XCTAssertTrue(loggedItems.contains(where: { $0.item == AnyTraceEquatable(1) }))
        
        // Try to log another item
        logger.log(item: AnyTraceEquatable(3))
        XCTAssertTrue(logger.loggedItems.count == 1)
        XCTAssertFalse(loggedItems.contains(where: { $0.item == AnyTraceEquatable(3) }))
    }
    
    func testClearing() {
        let logger = ItemLogger()
        logger.start()
        logger.log(item: AnyTraceEquatable("Hai"))
        XCTAssertTrue(logger.loggedItems.count == 1)
        logger.clear()
        XCTAssertTrue(logger.loggedItems.count == 0)
        
        logger.log(item: AnyTraceEquatable("Hello"))
        logger.log(item: AnyTraceEquatable("Alo"))
        XCTAssertTrue(logger.loggedItems.count == 2)
    }
    
}
