//
//  Tracers.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

struct Tracers {
    // This is just an example, but you can have many types
    // of tracers within a single app (e.g. analytics or any type of "event" system)
    //
    // We just create a single instance here, but you're free to architect however you wish
    static let analytics = AnalyticsTracer()
}
