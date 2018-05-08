//
//  TraceUISignals.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public struct TraceUISignals {
    
    internal struct Traces {
        static let showTraceDetail = TraceSignal<Traceable>()
        static let added = TraceSignal<[Traceable]>()
    }
    
    private init() {}
}
