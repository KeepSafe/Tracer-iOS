//
//  TraceUISignals.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

typealias TraceActionSignal = TraceSignal<()?>

internal struct TraceUISignals {
    
    internal struct Logger {
        static let itemLogged = ItemLoggedSignal()
    }
    
    internal struct Traces {
        static let added = TraceSignal<[Traceable]>()
        static let started = TraceSignal<(trace: Traceable, started: TraceStarted)>()
        static let itemLogged = TraceItemLoggedSignal()
        static let stateChanged = TraceStateChangedSignal()
        static let stopped = TraceSignal<(trace: Traceable, report: TraceReport)>()
    }
    
    internal struct UI {
        static let showLogger = TraceActionSignal()
        static let showTraces = TraceActionSignal()
        static let showTraceDetail = TraceSignal<Traceable>()
        static let startTrace = TraceActionSignal()
        static let stopTrace = TraceActionSignal()
        static let closeTraceDetail = TraceActionSignal()
        static let showSettings = TraceActionSignal()
        static let exportTrace = TraceActionSignal()
        static let traceReportExported = TraceSignal<TraceReport>()
        static let collapseTool = TraceActionSignal()
        static let expandTool = TraceActionSignal()
    }
    
    private init() {}
}
