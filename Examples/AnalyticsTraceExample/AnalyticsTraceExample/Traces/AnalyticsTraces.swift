//
//  AnalyticsTraces.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Tracer

enum AnalyticsTrace: String {
    case signupFlow,
         assertFlow
    
    var toTrace: Trace {
        switch self {
        case .signupFlow: return Trace(name: self.rawValue,
                                       itemsToMatch: AnalyticsEvent.traceItems(from: [.firstViewSeen,
                                                                                      .secondViewSeen,
                                                                                      .thirdViewSeen]))
        case .assertFlow: return Trace(name: self.rawValue,
                                       enforceOrder: true, // this is the default, but just being explicit here
                                       allowDuplicates: false,
                                       assertOnFailure: true,
                                       itemsToMatch: AnalyticsEvent.traceItems(from: [.firstViewSeen,
                                                                                      .secondViewSeen,
                                                                                      .thirdViewSeen]))
        }
    }
    
    // E.g. create a convenience property for displaying these in a UI list to start one that way
    static var allTraces: [Trace] {
        return [signupFlow.toTrace,
                assertFlow.toTrace]
    }
}
