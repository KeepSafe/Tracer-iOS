//
//  DictionaryItemLoggerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/21/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class DictionaryItemLoggerTests: XCTestCase {
    
    let loggedItemProperties: [String: AnyTraceEquatable] = ["test": AnyTraceEquatable("hello"), "test2": AnyTraceEquatable("goodbye")]
    
    func testDictionaryToDescriptionString() {
        XCTAssertTrue(loggedItemProperties.loggerDescription == "test: hello\ntest2: goodbye\n")
    }
    
    func testDictionaryToCSVString() {
        XCTAssertTrue(loggedItemProperties.csvDescription == "test: hello; test2: goodbye")
    }

}
