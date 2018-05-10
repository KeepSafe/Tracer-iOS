//
//  TraceUITabPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUITabPresenter: Presenting {
    
    init(view: TraceUITabView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Presenting
    
    func listenForChanges() {
        func showTracesList() {
            let viewModel = TraceUITabViewModel(showLogsTracesSegmentButton: true,
                                                showLogger: false,
                                                showCloseTraceDetailButton: false,
                                                showStartStopTraceButton: false,
                                                showTraceAsStarted: false,
                                                showSettingsButton: false,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        
        TraceUISignals.UI.showLogger.listen { newTraces in
            self.view.configure(with: TraceUITabViewModel.defaultConfiguration)
        }
        TraceUISignals.UI.showTraces.listen { newTraces in
            showTracesList()
        }
        TraceUISignals.Traces.started.listen { _ in
            self.isTraceRunning = true
        }
        TraceUISignals.Traces.stopped.listen { _ in
            self.isTraceRunning = false
        }
        TraceUISignals.UI.showTraceDetail.listen { newTraces in
            let viewModel = TraceUITabViewModel(showLogsTracesSegmentButton: false,
                                                showLogger: false,
                                                showCloseTraceDetailButton: true,
                                                showStartStopTraceButton: true,
                                                showTraceAsStarted: self.isTraceRunning,
                                                showSettingsButton: false,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.startTrace.listen { newTraces in
            let viewModel = TraceUITabViewModel(showLogsTracesSegmentButton: true,
                                                showLogger: true,
                                                showCloseTraceDetailButton: false,
                                                showStartStopTraceButton: false,
                                                showTraceAsStarted: true,
                                                showSettingsButton: true,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.stopTrace.listen { newTraces in
            let viewModel = TraceUITabViewModel(showLogsTracesSegmentButton: true,
                                                showLogger: true,
                                                showCloseTraceDetailButton: false,
                                                showStartStopTraceButton: false,
                                                showTraceAsStarted: false,
                                                showSettingsButton: true,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.closeTraceDetail.listen { newTraces in
            showTracesList()
        }
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUITabView
    private var isTraceRunning = false
}
