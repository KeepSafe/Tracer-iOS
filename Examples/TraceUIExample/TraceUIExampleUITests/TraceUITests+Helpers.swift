//
//  TraceUITests+Helpers.swift
//  TraceUIExampleUITests
//
//  Created by Rob Phillips on 5/21/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import XCTest

extension TraceUITests {
    
    func cell(containing label: String) -> XCUIElement {
        let matches = app.cells.containing(NSPredicate(format: "label CONTAINS %@", label))
        return matches.element(boundBy: 0)
    }
    
    func tapCell(containing label: String) {
        cell(containing: label).tap()
    }
    
    func cellExists(containing label: String) {
        XCTAssertTrue(cell(containing: label).exists)
    }
    
    func cellDoesNotExist(containing label: String) {
        XCTAssertFalse(cell(containing: label).exists)
    }
    
    func otherElementExists(withIdentifier identifier: String) -> Bool {
        let query = app.windows.otherElements.matching(identifier: identifier)
        if query.count == 0 { return false }
        return query.firstMatch.exists && query.firstMatch.isHittable
    }
    
    func verifyExists(containingText text: String) {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        let element = app.staticTexts.element(matching: predicate)
        waitAndVerify(exists: true, element: element)
    }
    
    func verifyExists(text: String) {
        waitAndVerify(exists: true, element: app.staticTexts[text])
    }
    
    func verifyNoLongerExists(text: String) {
        waitAndVerify(exists: false, element: app.staticTexts[text])
    }

    func waitAndVerify(exists: Bool, element: XCUIElement) {
        let exists = NSPredicate(format: "exists == \(exists ? "true" : "false")")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func tapButtonEventually(named name: String) {
        let predicate = NSPredicate(format: "label CONTAINS %@", name)
        let element = app.buttons.element(matching: predicate)
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        element.tap()
    }
    
}
