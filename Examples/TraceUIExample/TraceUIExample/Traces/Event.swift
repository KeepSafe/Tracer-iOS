//
//  Event.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum Event: String {
    case one
    case two
    case three
    
    var uxFlowHint: String {
        switch self {
        case .one: return "Press the 'Fire event 1' button"
        case .two: return "Press the 'Fire event 2' button"
        case .three: return "Press the 'Fire event 3' button"
        }
    }
    
    var toTraceItem: TraceItem {
        return TraceItem(type: "event", itemToMatch: AnyTraceEquatable(self), uxFlowHint: uxFlowHint)
    }
    
    static func traceItems(from events: [Event]) -> [TraceItem] {
        return events.map({ $0.toTraceItem })
    }
}
