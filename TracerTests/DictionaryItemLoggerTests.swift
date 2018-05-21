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
        XCTAssertTrue(string == "test: hello\ntest2: goodbye\n")
    }
    
    func testDictionaryToCSVString() {
        let csvString = loggedItemProperties.csvDescription
        XCTAssertTrue(csvString == "test: hello; test2: goodbye")
    }

}
