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
    case logicVerificationFlow = "Verify logic flow"
    
    var toTrace: Trace {
        switch self {
        case .logicVerificationFlow: return Trace(name: self.rawValue,
                                                  itemsToMatch: Event.traceItems(from: [.logicCheckpointOne,
                                                                                        .logicCheckpointTwo,
                                                                                        .logicCheckpointThree]),
                                                  setupSteps: ["Do this",
                                                               "Then do that",
                                                               "And finish with that other thing that's also really important"])
        }
    }
    
    // E.g. create a convenience property for displaying these in a UI list to start one that way
    static var allTraces: [Trace] {
        return [logicVerificationFlow.toTrace]
    }
}
