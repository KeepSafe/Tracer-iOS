//
//  EventTrace.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

import Tracer

enum EventTrace: String {
    case example1 = "Example 1: Order matters, duplicates don't"
    case example2 = "Example 2: No duplicates, order doesn't matter"
    
    var toTrace: Trace {
        switch self {
        case .example1:
            return Trace(name: self.rawValue,
                         itemsToMatch: Event.traceItems(from: [.one,
                                                               .two,
                                                               .three]),
                                                        setupSteps: ["Fire these in order 1-2-3 to pass",
                                                                     "Or fire them out-of-order or leave one missing to fail"])
        case .example2:
            return Trace(name: self.rawValue,
                         enforceOrder: false,
                         allowDuplicates: false,
                         assertOnFailure: true,
                         itemsToMatch: Event.traceItems(from: [.one,
                                                               .two,
                                                               .three]),
                         setupSteps: ["Order doesn't matter for this trace",
                                      "But it can't include duplicate events",
                                      "And it will assert when you fail"],
                         setupBeforeStartingTrace: {
                            print("STARTING ZE TRACE!")
                            // You can do other things here like setup the app
                            // state to prepare for this trace if you're using
                            // these for QA testing
                         })
        }
    }
    
    // E.g. create a convenience property for displaying these in a UI list to start one that way
    static var allTraces: [Trace] {
        return [example1.toTrace, example2.toTrace]
    }
}
