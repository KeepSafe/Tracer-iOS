//
//  EventTracer.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum Event: String {
    case logicCheckpointOne
    case logicCheckpointTwo
    case logicCheckpointThree
    
    var toTraceItem: TraceItem {
        return TraceItem(type: "event", itemToMatch: AnyTraceEquatable(self))
    }
    
    static func traceItems(from events: [Event]) -> [TraceItem] {
        return events.map({ $0.toTraceItem })
    }
}

struct EventTracer {
    
    static func log(event: Event) {
        print("\nEVENT: \(event.rawValue) logged")
    }
    
}
