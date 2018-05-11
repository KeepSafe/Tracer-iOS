//
//  TraceUITabViewModel.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

struct TraceUITabViewModel: ViewModeling {
    let traceName: String?
    let showLogsTracesSegmentButton: Bool
    let showLogger: Bool
    let showCloseTraceDetailButton: Bool
    let showStartStopTraceButton: Bool
    let startStopButtonState: StartStopButtonState
    let showSettingsButton: Bool
    let showExportTraceButton: Bool
    let showCollapseUIToolButton: Bool
    
    static let defaultConfiguration = TraceUITabViewModel(traceName: nil,
                                                          showLogsTracesSegmentButton: true,
                                                          showLogger: true,
                                                          showCloseTraceDetailButton: false,
                                                          showStartStopTraceButton: false,
                                                          startStopButtonState: .readyToStart,
                                                          showSettingsButton: true,
                                                          showExportTraceButton: false,
                                                          showCollapseUIToolButton: true)
}
