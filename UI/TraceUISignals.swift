//
//  TraceUISignals.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

internal struct TraceUISignals {
    
    internal struct Traces {
        static let added = TraceSignal<[Traceable]>()
        static let showDetail = TraceSignal<Traceable>()
        static let started = TraceSignal<(trace: Traceable, started: TraceStarted)>()
        static let itemLogged = TraceItemLoggedSignal()
        static let stateChanged = TraceStateChangedSignal()
        static let stopped = TraceSignal<(trace: Traceable, report: TraceReport)>()
    }
    
    internal struct Logger {
        static let itemLogged = ItemLoggedSignal()
    }
    
    private init() {}
}
