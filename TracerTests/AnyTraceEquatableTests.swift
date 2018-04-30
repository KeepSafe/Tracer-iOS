//
//  AnyTraceEquatableTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 4/26/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class AnyTraceEquatableTests: XCTestCase {
    
    let intBox = AnyTraceEquatable(1)
    let stringBox = AnyTraceEquatable("string")
    let arrayBox = AnyTraceEquatable(["a", "b", "c"])
    let setBox = AnyTraceEquatable(Set(["a", "b", "c"]))
    let dictionaryBox = AnyTraceEquatable(["key": "value"])
    let nestedDictionaryBox = AnyTraceEquatable(["dictionary": ["key": "value"]])
    let customBox = AnyTraceEquatable(_CustomTraceEquatable(name: "custom"))
    
    func testEquatableBoxingAndComparison() {
        XCTAssertTrue(intBox == AnyTraceEquatable(1))
        XCTAssertFalse(intBox == AnyTraceEquatable(2))
        XCTAssertFalse(intBox == AnyTraceEquatable(UInt(1)))
        
        XCTAssertTrue(stringBox == AnyTraceEquatable("string"))
        XCTAssertFalse(stringBox == AnyTraceEquatable("otherString"))
        XCTAssertFalse(stringBox == AnyTraceEquatable(NSString(string: "string")))
        
        XCTAssertTrue(arrayBox == AnyTraceEquatable(["a", "b", "c"]))
        XCTAssertFalse(arrayBox == AnyTraceEquatable(["b", "a", "c"])) // out of order
        XCTAssertFalse(arrayBox == AnyTraceEquatable(["a", "b", "d"]))
        XCTAssertFalse(arrayBox == AnyTraceEquatable(NSArray(array: ["a", "b", "c"])))
        
        XCTAssertTrue(setBox == AnyTraceEquatable(Set(["a", "b", "c"])))
        XCTAssertTrue(setBox == AnyTraceEquatable(Set(["b", "a", "c"]))) // order doesn't matter
        XCTAssertFalse(setBox == AnyTraceEquatable(Set(["a", "b", "d"])))
        XCTAssertFalse(setBox == AnyTraceEquatable(NSSet(array: ["a", "b", "c"])))
        
        XCTAssertTrue(dictionaryBox == AnyTraceEquatable(["key": "value"]))
        XCTAssertFalse(dictionaryBox == AnyTraceEquatable(["key": "otherValue"]))
        XCTAssertFalse(dictionaryBox == AnyTraceEquatable(NSDictionary(dictionary: ["key": "value"])))
        
        XCTAssertTrue(nestedDictionaryBox == AnyTraceEquatable(["dictionary": ["key": "value"]]))
        XCTAssertFalse(nestedDictionaryBox == AnyTraceEquatable(["dictionary": ["key": "otherValue"]]))
        XCTAssertFalse(nestedDictionaryBox == AnyTraceEquatable(NSDictionary(dictionary: ["dictionary": ["key": "value"]])))
        
        XCTAssertTrue(customBox == AnyTraceEquatable(_CustomTraceEquatable(name: "custom")))
        XCTAssertFalse(customBox == AnyTraceEquatable(_CustomTraceEquatable(name: "otherCustom")))
        XCTAssertFalse(customBox == AnyTraceEquatable(_CustomTraceEquatableTwo(name: "custom")))
    }
    
    func testEquatableBoxArrays() {
        let arrayOne = [intBox, stringBox, arrayBox, setBox, dictionaryBox, nestedDictionaryBox, customBox]
        let arrayTwo = [intBox, stringBox, arrayBox, setBox, dictionaryBox, nestedDictionaryBox, customBox]
        XCTAssertTrue(arrayOne == arrayTwo)
        
        let arrayThree = [customBox, intBox, stringBox, setBox, arrayBox, dictionaryBox, nestedDictionaryBox] // out of order
        XCTAssertFalse(arrayOne == arrayThree)
        
        let arrayFour = [intBox, stringBox]
        XCTAssertFalse(arrayOne == arrayFour)
    }
    
    func testEquatableBoxDictionaries() {
        let dictOne = ["k1": intBox, "k2": stringBox, "k3": arrayBox, "k4": setBox, "k5": dictionaryBox, "k6": nestedDictionaryBox, "k7": customBox]
        let dictTwo = ["k1": intBox, "k2": stringBox, "k3": arrayBox, "k4": setBox, "k5": dictionaryBox, "k6": nestedDictionaryBox, "k7": customBox]
        XCTAssertTrue(dictOne == dictTwo)
        
        let dictThree = ["k7": customBox, "k2": stringBox, "k3": arrayBox, "k4": setBox, "k5": dictionaryBox, "k6": nestedDictionaryBox, "k1": intBox]
        XCTAssertTrue(dictOne == dictThree) // out of order doesn't matter for dictionaries
        
        let dictFour = ["k1": intBox]
        XCTAssertFalse(dictOne == dictFour)
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
