//
//  TraceUISignals.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

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
        static let settingsAdded = TraceSignal<[UIAlertAction]>()
        static let showSettings = TraceSignal<UIButton>() // the settings button, for iPad popovers
        static let exportLog = TraceActionSignal()
        static let clearLog = TraceActionSignal()
        static let exportTrace = TraceActionSignal()
        static let traceReportExported = TraceSignal<TraceReport>()
        static let collapseTool = TraceActionSignal()
        static let expandTool = TraceActionSignal()
        static let show = TraceActionSignal()
        static let hide = TraceActionSignal()
        
        /// Broadcasts the touch point in the button's coordinate space
        static let statusButtonDragged = TraceSignal<(touchPoint: CGPoint, gestureState: UIGestureRecognizer.State)>()
    }
    
    internal struct Toasts {
        static let enable = TraceActionSignal()
        static let queue = TraceSignal<LoggedItem>()
        static let show = TraceSignal<TraceUIToast>()
        static let disable = TraceActionSignal()
    }
    
    private init() {}
}
