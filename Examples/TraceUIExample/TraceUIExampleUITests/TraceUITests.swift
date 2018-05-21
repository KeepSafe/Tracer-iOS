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
    
    func testPassingOrderMattersTrace() {
        verifyStatusButton(state: nil)
        
        expandTraceUI()
        showTracesList()
        tapCell(containing: "Example 1")
        verifyExists(containingText: "Example 1: Order matters")
        
        // Starting
        XCTAssertTrue(app.buttons["CloseTraceDetails"].exists)
        XCTAssertFalse(app.buttons["StopTrace"].exists)
        startTrace()
        XCTAssertTrue(app.buttons["StopTrace"].exists)
        
        // Initial state
        XCTAssertTrue(cell(containing: "Event: one").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: two").staticTexts["⏳"].exists)
        XCTAssertTrue(cell(containing: "Event: three").staticTexts["⏳"].exists)
        
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

        // Exporting
        app.buttons["ExportTraceReport"].tap()
        tapCancel()
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
    
}
