//
//  AnalyticsTraces.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum AnalyticsTrace: String {
    case signupFlow
    
    var toTrace: Trace {
        switch self {
        case .signupFlow: return Trace(name: self.rawValue,
                                       itemsToMatch: AnalyticsEvent.traceItems(from: [.firstViewSeen,
                                                                                      .secondViewSeen,
                                                                                      .thirdViewSeen]))
        }
    }
    
    // E.g. create a convenience property for displaying these in a UI list to start one that way
    static var allTraces: [Trace] {
        return [signupFlow.toTrace]
    }
}
