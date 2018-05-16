//
//  TraceSignalTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceSignalListenerTests: XCTestCase {
    
    func testInstantiationGeneratesID() {
        let listener = TraceSignalListener()
        XCTAssertFalse(listener.id.isEmpty)
    }
    
}

final class TraceSignalTests: XCTestCase {

    func testListenFireAndRemoveListener() {
        let firedExp = expectation(description: "signalFired")
        let signal = TraceSignal<String>()
        
        // Listen
        let listener = signal.listen { string in
            // test generic box value
            XCTAssertTrue(string == "hai")
            // and also that this fired
            firedExp.fulfill()
        }
        XCTAssertNotNil(listener)
        
        // Fire
        signal.fire(data: "hai")
        wait(for: [firedExp], timeout: 5)
        
        // Remove listener
        // Note: if we fire this a second time and it's called,
        // the expectation would fail by fulfilling more than once
        signal.remove(listener: listener)
        signal.fire(data: "doesntGetListenedTo")
    }
    
    func testRemoveAllListeners() {
        let signal = TraceSignal<String>()
        signal.listen { string in
            XCTFail("this should not be called")
        }
        signal.listen { string in
            XCTFail("this should not be called, either")
        }
        signal.removeAllListeners()
        signal.fire(data: "doesntGetListenedTo")
    }
    
}
