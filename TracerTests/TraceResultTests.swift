//
//  TraceResultTests.swift
//  TracerTests
//
//  Created by Rob Phillips on 5/2/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceResultTests: XCTestCase {
    
    fileprivate let testTraceItemTrue = TraceItem(type: "traceResultTestsTrue", itemToMatch: AnyTraceEquatable(true))
    fileprivate let testTraceItemFalse = TraceItem(type: "traceResultTestsFalse", itemToMatch: AnyTraceEquatable(false))
    fileprivate let ignoredItem = TraceItem(type: "ignoreMe", itemToMatch: AnyTraceEquatable(true))
    
    private let i1 = TraceItem(type: "1", itemToMatch: AnyTraceEquatable(1))
    private let i2 = TraceItem(type: "2", itemToMatch: AnyTraceEquatable(2))
    private let i3 = TraceItem(type: "3", itemToMatch: AnyTraceEquatable(3))
    private let i4 = TraceItem(type: "4", itemToMatch: AnyTraceEquatable(4))
    private let i5 = TraceItem(type: "5", itemToMatch: AnyTraceEquatable(5))
    private let i6 = TraceItem(type: "6", itemToMatch: AnyTraceEquatable(6))
    
    // MARK: - API

    func testInstantiationProperties() {
        let result = testResult(for: "instantiation")
        
        // Make sure it creates initial states for items to match
        XCTAssertFalse(result.statesForItemsToMatch.isEmpty)
        XCTAssertTrue(result.statesForItemsToMatch.count == 2)
        
        verifyMatchedItemState(in: result, firstItem: true, state: .waitingToBeMatched)
        verifyMatchedItemState(in: result, firstItem: false, state: .waitingToBeMatched)
        
        // Make sure no items have been logged yet
        XCTAssertTrue(result.statesForAllLoggedItems.isEmpty)
    }
    
    func testHandlingFiringOfItem() {
        var result = testResult(for: "firingOfItem")
        
        // Ensure it logs the item and updates the state
        verifyMatchedItemState(in: result, firstItem: true, state: .waitingToBeMatched)
        result.handleFiring(of: testTraceItemTrue)
        verifyMatchedItemState(in: result, firstItem: true, state: .matched)
        
        // Is a no-op if result is already finalized
        result.finalize()
        verifyMatchedItemState(in: result, firstItem: false, state: .missing)
        result.handleFiring(of: testTraceItemFalse)
        verifyMatchedItemState(in: result, firstItem: false, state: .missing)
    }
    
    func testFinalizing() {
        var result = testResult(for: "finalize")
        
        // Log an item so we have one matched
        result.handleFiring(of: testTraceItemTrue)
        
        // Finalize and see if it switched waiting items to missing
        verifyMatchedItemState(in: result, firstItem: false, state: .waitingToBeMatched)
        verifyMatchedItemState(in: result, firstItem: true, state: .matched)
        result.finalize()
        verifyMatchedItemState(in: result, firstItem: true, state: .matched)
        verifyMatchedItemState(in: result, firstItem: false, state: .missing)
    }
    
    func testStatesForAllLoggedItems() {
        var result = testResult(for: "finalize")
        
        // Log an item that will match and one that will be ignored
        result.handleFiring(of: testTraceItemTrue)
        result.handleFiring(of: ignoredItem)
        
        verifyLoggedItemState(in: result, item: ignoredItem, state: .ignoredNoMatch)
        verifyLoggedItemState(in: result, item: testTraceItemTrue, state: .matched)
        
        // Verify the false item wasn't logged
        XCTAssertNil(findItemInLog(in: result, item: testTraceItemFalse))
    }
    
    func testStateChanges() {
        var result = testResult(for: "stateChanges")
        
        // Waiting
        XCTAssertTrue(result.state == .waiting)
        
        // Passing (but not all the results in yet)
        result.handleFiring(of: testTraceItemTrue)
        XCTAssertTrue(result.state == .passing)
        
        // Passed (all items fired and it was finalized)
        result.handleFiring(of: testTraceItemFalse)
        XCTAssertTrue(result.state == .passing)
        result.finalize()
        XCTAssertTrue(result.state == .passed)
        
        // Failed (nothing logged so items were all missing)
        var failedResult = testResult(for: "failedStateChanges")
        XCTAssertTrue(failedResult.state == .waiting)
        failedResult.finalize()
        XCTAssertTrue(failedResult.state == .failed)
    }
    
    // MARK: - Categorization
    
    func testItemFiringCategorization() {
        // Ignored, no match
        var r1 = testResult(for: "ignored, no match")
        r1.handleFiring(of: ignoredItem)
        verifyLoggedItemState(in: r1, item: ignoredItem, state: .ignoredNoMatch)

        // Matched
        var r2 = testResult(for: "matched")
        r2.handleFiring(of: testTraceItemTrue)
        r2.handleFiring(of: testTraceItemFalse)
        verifyLoggedItemState(in: r2, item: testTraceItemTrue, state: .matched)
        verifyLoggedItemState(in: r2, item: testTraceItemFalse, state: .matched)
        
        // Out-of-order
        var r3 = testResult(for: "out-of-order")
        r3.handleFiring(of: testTraceItemFalse)
        r3.handleFiring(of: testTraceItemTrue)
        verifyMatchedItemState(in: r3, firstItem: false, state: .outOfOrder)
        verifyMatchedItemState(in: r3, firstItem: true, state: .outOfOrder)
        
        // Ignored, but matched
        var r4 = testResult(for: "ignored, but matched")
        r4.handleFiring(of: testTraceItemTrue)
        verifyLoggedItemState(in: r4, item: testTraceItemTrue, state: .matched)
        // Fire it again and it should ignore it since all items
        // of this type were already consumed
        r4.handleFiring(of: testTraceItemTrue)
        verifyLoggedItemState(in: r4, item: testTraceItemTrue, state: .ignoredButMatched)
    }
    
    // MARK: - Order Logic
    
    func testCorrectOrderPasses() {
        var result = testResult(for: "correctOrder")
        result.handleFiring(of: testTraceItemTrue)
        result.handleFiring(of: testTraceItemFalse)
        XCTAssertTrue(result.state == .passing)
        result.finalize()
        XCTAssertTrue(result.state == .passed)
    }
    
    func testCorrectOrderWithMultipleOfEachTypePasses() {
        let trace = Trace(name: "multipleTypeCorrectOrder",
                          itemsToMatch: [i1, i1, i2, i3, i3, i4, i5, i6])
        
        var result = TraceResult(trace: trace)
        result.handleFiring(of: i1)
        result.handleFiring(of: i1)
        result.handleFiring(of: i2)
        result.handleFiring(of: i3)
        result.handleFiring(of: i3)
        result.handleFiring(of: i4)
        result.handleFiring(of: i5)
        result.handleFiring(of: i6)
        result.finalize()
        XCTAssertTrue(result.state == .passed)
    }
    
    func testIncorrectOrderFails() {
        var result = testResult(for: "incorrectOrder")
        result.handleFiring(of: testTraceItemFalse)
        XCTAssertTrue(result.state == .failed)
        result.handleFiring(of: testTraceItemTrue)
        XCTAssertTrue(result.state == .failed)
        result.finalize()
        XCTAssertTrue(result.state == .failed)
    }
    
    func testAnotherIncorrectOrderFails() {
        let trace = Trace(name: "anotherIncorrectOrder",
                          itemsToMatch: [i1, i2, i3, i4, i5, i6])
        
        // Fire them in arbitrary orders
        var r1 = TraceResult(trace: trace)
        r1.handleFiring(of: i1)
        XCTAssertTrue(r1.state == .passing)
        r1.handleFiring(of: i6)
        XCTAssertTrue(r1.state == .failed)
        r1.handleFiring(of: i2)
        r1.handleFiring(of: i3)
        r1.handleFiring(of: i4)
        r1.handleFiring(of: i5)
        r1.handleFiring(of: i6)
        XCTAssertTrue(r1.state == .failed)
        
        var r2 = TraceResult(trace: trace)
        r2.handleFiring(of: i1)
        r2.handleFiring(of: i1)
        r2.handleFiring(of: i2)
        r2.handleFiring(of: i3)
        r2.handleFiring(of: i4)
        r2.handleFiring(of: i6)
        r2.handleFiring(of: i5)
        XCTAssertTrue(r1.state == .failed)
    }
    
    func testOrderNotEnforced() {
        let trace = Trace(name: "orderNotEnforced",
                          enforceOrder: false,
                          itemsToMatch: [i1, i2, i3, i4, i5, i6])
        
        // Fire them in arbitrary orders
        var r1 = TraceResult(trace: trace)
        r1.handleFiring(of: i1)
        r1.handleFiring(of: i6)
        r1.handleFiring(of: i3)
        r1.handleFiring(of: i5)
        r1.handleFiring(of: i4)
        r1.handleFiring(of: i1)
        r1.handleFiring(of: i1)
        r1.handleFiring(of: i2)
        r1.finalize()
        XCTAssertTrue(r1.state == .passed)
    }
    
}

// MARK: - Private Helpers

fileprivate extension TraceResultTests {

    func testResult(for traceName: String, enforceOrder: Bool = true) -> TraceResult {
        let trace = Trace(name: traceName, enforceOrder: enforceOrder, itemsToMatch: [testTraceItemTrue, testTraceItemFalse])
        return TraceResult(trace: trace)
    }
    
    func verifyMatchedItemState(in result: TraceResult, firstItem isFirstItem: Bool, state: TraceItemState) {
        if isFirstItem {
            let firstItem = result.statesForItemsToMatch.first!
            let firstTraceItem = firstItem.keys.first
            let firstItemState = firstItem.values.first
            XCTAssertTrue(firstTraceItem == testTraceItemTrue)
            XCTAssertTrue(firstItemState == state)
        } else {
            let lastItem = result.statesForItemsToMatch.last!
            let lastTraceItem = lastItem.keys.first
            let lastItemState = lastItem.values.first
            XCTAssertTrue(lastTraceItem == testTraceItemFalse)
            XCTAssertTrue(lastItemState == state)
        }
    }
    
    func findItemInLog(in result: TraceResult, item: TraceItem) -> TraceItemStateDictionary? {
        guard let foundItem = result.statesForAllLoggedItems.first(where: { $0.keys.first == item }) else {
            return nil
        }
        return foundItem
    }
    
    func verifyLoggedItemState(in result: TraceResult, item: TraceItem, state: TraceItemState) {
        guard result.statesForAllLoggedItems.first(where: { $0.keys.first == item && $0.values.first == state }) != nil else {
            XCTFail("Item (\(item.type)) with that state (\(state.rawValue)) not found")
            return
        }
    }
    
}
