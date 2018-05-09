//
//  LoggedItemTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class LoggedItemTests: XCTestCase {
    
    func testInstantiationProperties() {
        let anyItem = AnyTraceEquatable("Hello")
        let li = LoggedItem(anyItem)
        XCTAssertTrue(li.item == anyItem)
        let timestampIsFresh = (Date().timeIntervalSinceNow - li.timestamp.timeIntervalSinceNow) < 3
        XCTAssertTrue(timestampIsFresh)
    }

}
