//
//  TraceUITests.swift
//  TraceUIExampleUITests
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest
@testable import Tracer

final class TraceUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearSavedButtonLocations()
    }
    
    // MARK: - UI Tool
    
    func testExpandCollapse() {
        XCTAssertFalse(otherElementExists(withIdentifier: "TraceUISplitView"))
        expandTraceUI()
        XCTAssertTrue(otherElementExists(withIdentifier: "TraceUISplitView"))
        collapseTraceUI()
        XCTAssertFalse(otherElementExists(withIdentifier: "TraceUISplitView"))
    }
    
    func testLoggerAndTracesTabs() {
        expandTraceUI()
        cellExists(containing: "⚡️ Logged a number! It was 1")
        XCTAssertTrue(app.buttons["ShowTraceSettings"].exists)
        showTracesList()
        XCTAssertFalse(app.buttons["ShowTraceSettings"].exists)
        cellExists(containing: "Example 1: Order matters, duplicates don't")
        cellExists(containing: "Example 2: No duplicates, order doesn't matter")
    }
    
    func testSettings() {
        expandTraceUI()
        tapSettings()
        tapCancel()
        
        // Clearing log
        cellExists(containing: "⚡️ Logged a number! It was 1")
        tapSettings()
        let actionSheet = app.sheets["Settings"]
        actionSheet.buttons["Clear log"].tap()
        cellDoesNotExist(containing: "⚡️ Logged a number! It was 1")
        
        // Mooing like a cow
        cellDoesNotExist(containing: "🐄 Moooooooooo")
        tapSettings()
        actionSheet.buttons["Moo like a cow"].tap()
        cellExists(containing: "🐄 Moooooooooo")
    }
    
    func testStartingStoppingNavigation() {
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 1")
        startTrace()
        stopTrace()
        closeTraceDetail()
    }
    
    func testPassingOrderMattersTrace() {
        verifyStatusButton(state: nil)
        
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 1")
        verifyExists(containingText: "Example 1: Order matters")
        
        // Starting
        XCTAssertTrue(app.tables.staticTexts["Setup steps:\n\n1. Fire these in order 1-2-3 to pass\n2. Or fire them out-of-order or leave one missing to fail\n"].exists)
        XCTAssertTrue(app.buttons["CloseTraceDetails"].exists)
        XCTAssertFalse(app.buttons["StopTrace"].exists)
        startTrace()
        XCTAssertTrue(app.buttons["StopTrace"].exists)
        
        // Initial state
        ensureExampleInitialState()
        
        // Test we're in a waiting state
        collapseTraceUI()
        verifyStatusButton(state: .waiting)
        expandTraceUI()
        
        // Log an item without collapsing
        dragAndResize(downwards: true)
        app.buttons["Fire event 1"].tap()
        waitAndVerify(exists: true, element: cell(containing: "Event: one").staticTexts["✅"])
        collapseTraceUI()
        verifyStatusButton(state: .passing)
        expandTraceUI()
        
        // Then collapse and log more
        collapseTraceUI()
        app.buttons["Fire event 2"].tap()
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .passing)
        expandTraceUI()
        dragAndResize(downwards: false)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["✅"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["✅"].exists)

        // Stopping
        XCTAssertFalse(app.buttons["StartTrace"].exists)
        stopTrace()
        XCTAssertFalse(app.buttons["StartTrace"].exists)
        XCTAssertTrue(app.buttons["CloseTraceDetails"].exists)
    }
    
    func testFailingOrderMattersTrace() {
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 1")
        startTrace()
        ensureExampleInitialState()
        
        // Fail the test
        collapseTraceUI()
        verifyStatusButton(state: .waiting)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .failed)
        expandTraceUI()
        XCTAssertTrue(cell(containing: "Event: one").staticTexts["❌"].exists)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["❌"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["❌"].exists)
    }
    
    func testPassingDuplicatesMattersTrace() {
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 2")
        startTrace()
        ensureExampleInitialState()
        
        // Pass the test by firing out-of-order
        collapseTraceUI()
        verifyStatusButton(state: .waiting)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .passing)
        app.buttons["Fire event 1"].tap()
        verifyStatusButton(state: .passing)
        app.buttons["Fire event 2"].tap()
        verifyStatusButton(state: .passing)
        expandTraceUI()
        XCTAssertTrue(cell(containing: "Event: one").staticTexts["✅"].exists)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["✅"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["✅"].exists)
    }
    
    func testFailingDuplicatesMattersTrace() {
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 2")
        startTrace()
        ensureExampleInitialState()
        
        // Fail the test
        collapseTraceUI()
        verifyStatusButton(state: .waiting)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .passing)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .failed)
        expandTraceUI()
        XCTAssertTrue(cell(containing: "Event: one").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["❌"].exists)
    }

    func testIgnoringAssertionsDuringUIToolUsage() {
        // Note: example 2 has assertions turned on for failures, but the UI tool should ignore this
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 2")
        startTrace()
        ensureExampleInitialState()

        // Pass the test by firing out-of-order
        collapseTraceUI()
        verifyStatusButton(state: .waiting)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .passing)
        app.buttons["Fire event 3"].tap()
        verifyStatusButton(state: .failed)
        expandTraceUI()
        XCTAssertTrue(cell(containing: "Event: one").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["❌"].exists)
    }
    
    // MARK: - Toasts
    
    func testToasts() {
        func toastText(number: Int) -> String {
            return "⚡️ Logged a number! It was \(number)\n\nexample: [\"myAwesomeKey\": \"someAmazingValue\"] "
        }
        let t2 = toastText(number: 2)
        let t3 = toastText(number: 3)
        let t4 = toastText(number: 4)
        
        verifyExists(text: t2)
        verifyNoLongerExists(text: t2)
        verifyExists(text: t3)
        verifyNoLongerExists(text: t3)
        verifyExists(text: t4)
        verifyNoLongerExists(text: t4)
    }
    
}

// MARK: - Private API

private extension TraceUITests {
    
    func expandTraceUI() {
        app.buttons["ExpandTraceUI"].tap()
    }
    
    func collapseTraceUI() {
        app.buttons["CollapseTraceUI"].tap()
    }
    
    func tapSettings() {
        app.buttons["ShowTraceSettings"].tap()
    }
    
    func showLoggerList() {
        app.buttons["Logger"].tap()
    }
    
    func showTracesList() {
        app.buttons["Start a trace"].tap()
    }
    
    func startTrace() {
        app.buttons["StartTrace"].tap()
    }
    
    func stopTrace() {
        app.buttons["StopTrace"].tap()
    }
    
    func closeTraceDetail() {
        app.buttons["CloseTraceDetails"].tap()
    }
    
    func dragAndResize(downwards: Bool) {
        let dragView = app.otherElements["TraceUIDragToResizeView"]
        let fromCoordinate = dragView.coordinate(withNormalizedOffset: .zero)
        let toCoordinate = dragView.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: downwards ? 5 : -5))
        fromCoordinate.press(forDuration: 0, thenDragTo: toCoordinate)
    }
    
    func clearSavedButtonLocations() {
        if (app.buttons["CollapseTraceUI"].waitForExistence(timeout: 1) && app.buttons["CollapseTraceUI"].isHittable) {
            collapseTraceUI()
        }
        app.buttons["UI test helpers"].tap()
        app.buttons["Clear saved button locations"].tap()
    }
    
    func verifyStatusButton(state: TraceState?) {
        let expandButton = app.buttons["ExpandTraceUI"]
        let statusValue = expandButton.value as? String
        if let state = state {
            XCTAssertTrue(statusValue == "state = \(state)")
        } else {
            XCTAssertTrue(statusValue == "state = inactive")
        }
    }
    
    func tapCancel() {
        tapButtonEventually(named: "Cancel")
    }
    
    func ensureExampleInitialState() {
        let cellOne = cell(containing: "Event: one")
        let cellTwo = cell(containing: "Event: two")
        let cellThree = cell(containing: "Event: three")
        XCTAssertTrue(cellOne.staticTexts["⏳"].exists)
        XCTAssertTrue(cellOne.staticTexts["UX flow: Press the 'Fire event 1' button"].exists)
        XCTAssertTrue(cellTwo.staticTexts["⏳"].exists)
        XCTAssertTrue(cellTwo.staticTexts["UX flow: Press the 'Fire event 2' button"].exists)
        XCTAssertTrue(cellThree.staticTexts["⏳"].exists)
        XCTAssertTrue(cellThree.staticTexts["UX flow: Press the 'Fire event 3' button"].exists)
    }
    
}
