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
        let string = loggedItemProperties.loggerDescription
        XCTAssertTrue(string == "test: hello\ntest2: goodbye\n" || string == "test2: goodbye\ntest: hello\n")
    }
    
    func testDictionaryToCSVString() {
        let string = loggedItemProperties.csvDescription
        XCTAssertTrue(string == "test: hello; test2: goodbye" || string == "test2: goodbye; test: hello")
    }

}
