//
//  TracerTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 4/26/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

class AnyTraceEquatableTests: XCTestCase {
    
    func testEquatableBoxingAndComparison() {
        let intBox = AnyTraceEquatable(1)
        XCTAssertTrue(intBox == AnyTraceEquatable(1))
        XCTAssertFalse(intBox == AnyTraceEquatable(2))
        XCTAssertFalse(intBox == AnyTraceEquatable(UInt(1)))
        
        let stringBox = AnyTraceEquatable("string")
        XCTAssertTrue(stringBox == AnyTraceEquatable("string"))
        XCTAssertFalse(stringBox == AnyTraceEquatable("otherString"))
        XCTAssertFalse(stringBox == AnyTraceEquatable(NSString(string: "string")))
        
        let arrayBox = AnyTraceEquatable(["a", "b", "c"])
        XCTAssertTrue(arrayBox == AnyTraceEquatable(["a", "b", "c"]))
        XCTAssertFalse(arrayBox == AnyTraceEquatable(["b", "a", "c"])) // out of order
        XCTAssertFalse(arrayBox == AnyTraceEquatable(["a", "b", "d"]))
        XCTAssertFalse(arrayBox == AnyTraceEquatable(NSArray(array: ["a", "b", "c"])))
        
        let dictionaryBox = AnyTraceEquatable(["key": "value"])
        XCTAssertTrue(dictionaryBox == AnyTraceEquatable(["key": "value"]))
        XCTAssertFalse(dictionaryBox == AnyTraceEquatable(["key": "otherValue"]))
        XCTAssertFalse(dictionaryBox == AnyTraceEquatable(NSDictionary(dictionary: ["key": "value"])))
        
        let nestedDictionaryBox = AnyTraceEquatable(["dictionary": ["key": "value"]])
        XCTAssertTrue(nestedDictionaryBox == AnyTraceEquatable(["dictionary": ["key": "value"]]))
        XCTAssertFalse(nestedDictionaryBox == AnyTraceEquatable(["dictionary": ["key": "otherValue"]]))
        XCTAssertFalse(nestedDictionaryBox == AnyTraceEquatable(NSDictionary(dictionary: ["dictionary": ["key": "value"]])))
        
        let customBox = AnyTraceEquatable(_CustomTraceEquatable(name: "custom"))
        XCTAssertTrue(customBox == AnyTraceEquatable(_CustomTraceEquatable(name: "custom")))
        XCTAssertFalse(customBox == AnyTraceEquatable(_CustomTraceEquatable(name: "otherCustom")))
        XCTAssertFalse(customBox == AnyTraceEquatable(_CustomTraceEquatableTwo(name: "custom")))
    }
    
}

fileprivate struct _CustomTraceEquatable: Equatable {
    let name: String
    
    static func == (lhs: _CustomTraceEquatable, rhs: _CustomTraceEquatable) -> Bool {
        return lhs.name == rhs.name
    }
}

fileprivate struct _CustomTraceEquatableTwo: Equatable {
    let name: String
    
    static func == (lhs: _CustomTraceEquatableTwo, rhs: _CustomTraceEquatableTwo) -> Bool {
        return lhs.name == rhs.name
    }
}
