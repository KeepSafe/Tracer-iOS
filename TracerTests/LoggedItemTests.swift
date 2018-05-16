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
        let dictionary = AnyTraceEquatable(["hai": "there"])
        let properties =  ["test": dictionary]
        let li = LoggedItem(item: anyItem, properties: properties)
        XCTAssertTrue(li.item == anyItem)
        XCTAssertTrue(li.properties == properties)
        let timestampIsFresh = (Date().timeIntervalSinceNow - li.timestamp.timeIntervalSinceNow) < 3
        XCTAssertTrue(timestampIsFresh)
    }

}
