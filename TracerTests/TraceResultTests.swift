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
        let ignoredItem = TraceItem(type: "ignoreMe", itemToMatch: AnyTraceEquatable(true))
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
        
    }
    
    // MARK: - Order Logic
    
    func testCorrectOrderPasses() {
        
    }
    
    func testIncorrectOrderFails() {
        
    }
    
    func testOrderNotEnforced() {
        
    }
    
}

// MARK: - Private Helpers

fileprivate extension TraceResultTests {

    func testResult(for traceName: String) -> TraceResult {
        let trace = Trace(name: traceName, itemsToMatch: [testTraceItemTrue, testTraceItemFalse])
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
        guard let foundItem = findItemInLog(in: result, item: item) else {
            XCTFail("Item was never logged")
            return
        }
        let foundItemState = foundItem.values.first!
        XCTAssertTrue(foundItemState == state)
    }
    
}
