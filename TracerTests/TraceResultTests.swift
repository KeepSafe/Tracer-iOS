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
    
    fileprivate let ti1 = TraceItem(type: "ti1", itemToMatch: AnyTraceEquatable(true))
    fileprivate let ti2 = TraceItem(type: "ti2", itemToMatch: AnyTraceEquatable(false))
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
        XCTAssertNotNil(result.startTime)
        
        verifyMatchedItemState(in: result, item: ti1, state: .waitingToBeMatched)
        verifyMatchedItemState(in: result, item: ti2, state: .waitingToBeMatched)
        
        // Make sure no items have been logged yet
        XCTAssertTrue(result.statesForAllLoggedItems.isEmpty)
    }
    
    func testHandlingFiringOfItem() {
        let result = testResult(for: "firingOfItem")
        
        // Ensure it logs the item and updates the state
        verifyMatchedItemState(in: result, item: ti1, state: .waitingToBeMatched)
        result.handleFiring(of: ti1)
        verifyMatchedItemState(in: result, item: ti1, state: .matched)
        
        // Is a no-op if result is already finalized
        result.finalize()
        verifyMatchedItemState(in: result, item: ti2, state: .missing)
        result.handleFiring(of: ti2)
        verifyMatchedItemState(in: result, item: ti2, state: .missing)
    }
    
    func testFinalizing() {
        let result = testResult(for: "finalize")
        
        // Log an item so we have one matched
        result.handleFiring(of: ti1)
        
        // Finalize and see if it switched waiting items to missing
        verifyMatchedItemState(in: result, item: ti2, state: .waitingToBeMatched)
        verifyMatchedItemState(in: result, item: ti1, state: .matched)
        result.finalize()
        XCTAssertNotNil(result.endTime)
        verifyMatchedItemState(in: result, item: ti1, state: .matched)
        verifyMatchedItemState(in: result, item: ti2, state: .missing)
    }
    
    func testStatesForAllLoggedItems() {
        let result = testResult(for: "finalize")
        
        // Log an item that will match and one that will be ignored
        result.handleFiring(of: ti1)
        result.handleFiring(of: ignoredItem)
        
        verifyLoggedItemState(in: result, item: ignoredItem, state: .ignoredNoMatch)
        verifyLoggedItemState(in: result, item: ti1, state: .matched)
        
        // Verify the false item wasn't logged
        XCTAssertNil(findItemInLog(in: result, item: ti2))
    }
    
    func testStateChanges() {
        let result = testResult(for: "stateChanges")
        
        // Waiting
        XCTAssertTrue(result.state == .waiting)
        
        // Passing (but not all the results in yet)
        result.handleFiring(of: ti1)
        XCTAssertTrue(result.state == .passing)
        
        // Passed (all items fired and it was finalized)
        result.handleFiring(of: ti2)
        XCTAssertTrue(result.state == .passing)
        result.finalize()
        XCTAssertTrue(result.state == .passed)
        
        // Failed (nothing logged so items were all missing)
        let failedResult = testResult(for: "failedStateChanges")
        XCTAssertTrue(failedResult.state == .waiting)
        failedResult.finalize()
        XCTAssertTrue(failedResult.state == .failed)
    }
    
    // MARK: - Categorization
    
    func testItemFiringCategorization() {
        // Ignored, no match
        let r1 = testResult(for: "ignored, no match")
        r1.handleFiring(of: ignoredItem)
        verifyLoggedItemState(in: r1, item: ignoredItem, state: .ignoredNoMatch)

        // Matched
        let r2 = testResult(for: "matched")
        r2.handleFiring(of: ti1)
        r2.handleFiring(of: ti2)
        verifyLoggedItemState(in: r2, item: ti1, state: .matched)
        verifyLoggedItemState(in: r2, item: ti2, state: .matched)
        
        // Out-of-order
        let r3 = testResult(for: "out-of-order")
        r3.handleFiring(of: ti2)
        r3.handleFiring(of: ti1)
        verifyMatchedItemState(in: r3, item: ti2, state: .outOfOrder)
        verifyMatchedItemState(in: r3, item: ti1, state: .outOfOrder)
        
        // Ignored, but matched
        let r4 = testResult(for: "ignored, but matched")
        r4.handleFiring(of: ti1)
        verifyLoggedItemState(in: r4, item: ti1, state: .matched)
        // Fire it again and it should ignore it since all items
        // of this type were already consumed
        r4.handleFiring(of: ti1)
        verifyLoggedItemState(in: r4, item: ti1, state: .ignoredButMatched)
        
        // Duplicate, or Had duplicates
        let r5 = testResult(for: "duplicates", allowDuplicates: false)
        r5.handleFiring(of: ti1)
        r5.handleFiring(of: ti1)
        verifyMatchedItemState(in: r5, item: ti1, state: .hadDuplicates)
        verifyLoggedItemState(in: r5, item: ti1, state: .duplicate)
    }
    
    // MARK: - Order Logic
    
    func testCorrectOrderPasses() {
        let result = testResult(for: "correctOrder")
        result.handleFiring(of: ti1)
        result.handleFiring(of: ti2)
        XCTAssertTrue(result.state == .passing)
        result.finalize()
        XCTAssertTrue(result.state == .passed)
    }
    
    func testCorrectOrderWithMultipleOfEachTypePasses() {
        let trace = Trace(name: "multipleTypeCorrectOrder",
                          itemsToMatch: [i1, i1, i2, i3, i3, i4, i5, i6])
        
        let result = TraceResult(trace: trace)
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
        let result = testResult(for: "incorrectOrder")
        result.handleFiring(of: ti2)
        XCTAssertTrue(result.state == .failed)
        result.handleFiring(of: ti1)
        XCTAssertTrue(result.state == .failed)
        result.finalize()
        XCTAssertTrue(result.state == .failed)
    }
    
    func testAnotherIncorrectOrderFails() {
        let trace = Trace(name: "anotherIncorrectOrder",
                          itemsToMatch: [i1, i2, i3, i4, i5, i6])
        
        // Fire them in arbitrary orders
        let r1 = TraceResult(trace: trace)
        r1.handleFiring(of: i1)
        XCTAssertTrue(r1.state == .passing)
        r1.handleFiring(of: i6)
        XCTAssertTrue(r1.state == .failed)
        
        // Verify we don't put extra item dictionaries in when updating prior order (a prior bug)
        for itemDictionary in r1.statesForItemsToMatch {
            XCTAssertTrue(itemDictionary.keys.count == 1, "Too many items found; should only have one item in each dictionary")
        }
        
        r1.handleFiring(of: i2)
        r1.handleFiring(of: i3)
        r1.handleFiring(of: i4)
        r1.handleFiring(of: i5)
        r1.handleFiring(of: i6)
        XCTAssertTrue(r1.state == .failed)
        
        let r2 = TraceResult(trace: trace)
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
        let r1 = TraceResult(trace: trace)
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
    
    // MARK: - Duplicates
    
    func testEnforcingNoDuplicates() {
        let trace = Trace(name: "noDuplicatesAllowed",
                          allowDuplicates: false,
                          itemsToMatch: [i1, i2, i3, i4, i5, i6])
        
        // Fire a passing state, but fail on duplicates
        let r1 = TraceResult(trace: trace)
        r1.handleFiring(of: i1)
        r1.handleFiring(of: i2)
        r1.handleFiring(of: i3)
        r1.handleFiring(of: i4)
        r1.handleFiring(of: i5)
        r1.handleFiring(of: i6)
        XCTAssertTrue(r1.state == .passing)
        r1.handleFiring(of: i1)
        XCTAssertTrue(r1.state == .failed)
        r1.finalize()
        XCTAssertTrue(r1.state == .failed)
        // Ensure we marked it as `hadDuplicates` and `duplicate`
        verifyMatchedItemState(in: r1, item: i1, state: .hadDuplicates)
        verifyLoggedItemState(in: r1, item: i1, state: .duplicate)
        
        // Fail with duplicates early on
        let r2 = TraceResult(trace: trace)
        r2.handleFiring(of: i1)
        XCTAssertTrue(r2.state == .passing)
        r2.handleFiring(of: i1)
        XCTAssertTrue(r2.state == .failed)
        r2.handleFiring(of: i2)
        r2.handleFiring(of: i3)
        r2.handleFiring(of: i4)
        r2.handleFiring(of: i5)
        r2.handleFiring(of: i6)
        r2.finalize()
        XCTAssertTrue(r2.state == .failed)
        // Ensure we marked it as `hadDuplicates` and `duplicate`
        verifyMatchedItemState(in: r1, item: i1, state: .hadDuplicates)
        verifyLoggedItemState(in: r1, item: i1, state: .duplicate)
    }
    
    func testEnforcingNoOrderAndNoDuplicates() {
        let trace = Trace(name: "noDuplicatesAllowedAndNoOrderEnforced",
                          enforceOrder: false,
                          allowDuplicates: false,
                          itemsToMatch: [i1, i2, i3, i4, i5, i6])
        
        // Fire in random order, but only fail on duplicates
        let r1 = TraceResult(trace: trace)
        r1.handleFiring(of: i3)
        r1.handleFiring(of: i2)
        r1.handleFiring(of: i1)
        r1.handleFiring(of: i6)
        r1.handleFiring(of: i5)
        r1.handleFiring(of: i4)
        XCTAssertTrue(r1.state == .passing)
        r1.handleFiring(of: i1)
        XCTAssertTrue(r1.state == .failed)
        r1.finalize()
        XCTAssertTrue(r1.state == .failed)
        // Ensure we marked it as `hadDuplicates` and `duplicate`
        verifyMatchedItemState(in: r1, item: i1, state: .hadDuplicates)
        verifyLoggedItemState(in: r1, item: i1, state: .duplicate)
        
    }
    
}

// MARK: - Private Helpers

fileprivate extension TraceResultTests {

    func testResult(for traceName: String, enforceOrder: Bool = true, allowDuplicates: Bool = true) -> TraceResult {
        let trace = Trace(name: traceName, enforceOrder: enforceOrder, allowDuplicates: allowDuplicates, itemsToMatch: [ti1, ti2])
        return TraceResult(trace: trace)
    }
    
    func findItemInLog(in result: TraceResult, item: TraceItem) -> TraceItemStateDictionary? {
        guard let foundItem = result.statesForAllLoggedItems.first(where: { $0.keys.first == item }) else {
            return nil
        }
        return foundItem
    }
    
    func verifyMatchedItemState(in result: TraceResult, item: TraceItem, state: TraceItemState) {
        guard result.statesForItemsToMatch.first(where: { $0.keys.first == item && $0.values.first == state }) != nil else {
            XCTFail("Item (\(item.type)) with that state (\(state.rawValue)) not found")
            return
        }
    }
    
    func verifyLoggedItemState(in result: TraceResult, item: TraceItem, state: TraceItemState) {
        guard result.statesForAllLoggedItems.first(where: { $0.keys.first == item && $0.values.first == state }) != nil else {
            XCTFail("Item (\(item.type)) with that state (\(state.rawValue)) not found")
            return
        }
    }
    
}
