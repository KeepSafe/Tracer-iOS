//
//  TraceUITabViewModel.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

struct TraceUITabViewModel: ViewModeling {
    let showLogsTracesSegmentButton: Bool
    let showLogger: Bool
    let showCloseTraceDetailButton: Bool
    let showStartStopTraceButton: Bool
    let showTraceAsStarted: Bool
    let showSettingsButton: Bool
    let showExportTraceButton: Bool
    let showCollapseUIToolButton: Bool
    
    static let defaultConfiguration = TraceUITabViewModel(showLogsTracesSegmentButton: true,
                                                          showLogger: true,
                                                          showCloseTraceDetailButton: false,
                                                          showStartStopTraceButton: false,
                                                          showTraceAsStarted: false,
                                                          showSettingsButton: true,
                                                          showExportTraceButton: false,
                                                          showCollapseUIToolButton: true)
}
