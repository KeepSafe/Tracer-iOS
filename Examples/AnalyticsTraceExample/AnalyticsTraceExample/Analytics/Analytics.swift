//
//  Analytics.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum AnalyticsEvent: String {
    case firstViewSeen
    case secondViewSeen
    case thirdViewSeen
    
    var toTraceItem: TraceItem {
        return TraceItem(type: "event", itemToMatch: AnyTraceEquatable(self))
    }
    
    static func traceItems(from events: [AnalyticsEvent]) -> [TraceItem] {
        return events.map({ $0.toTraceItem })
    }
}

struct Analytics {
    
    static func log(event: AnalyticsEvent) {
        print("\n\nANALYTICS: \(event.rawValue) logged")
        
        Tracers.analytics.activeTracer?.log(item: event.toTraceItem)
    }
    
}
