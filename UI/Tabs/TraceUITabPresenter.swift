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
        TraceUISignals.UI.closeTraceDetail.listen { _ in
            DispatchQueue.inMain(after: TraceUI.Animation.duration * 2, work: {
                self.trace = nil
            })
        }
        
        listenForUIChanges()
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUITabView
    private var trace: Traceable?
    
    private var traceName: String {
        return trace?.name ?? ""
    }
}

private extension TraceUITabPresenter {
    
    func listenForUIChanges() {
        func showTracesList() {
            let viewModel = TraceUITabViewModel(traceName: traceName,
                                                showLogsTracesSegmentButton: true,
                                                showLogger: false,
                                                showCloseTraceDetailButton: false,
                                                showStartStopTraceButton: false,
                                                startStopButtonState: .hidden,
                                                showSettingsButton: false,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        
        TraceUISignals.UI.showLogger.listen { _ in
            self.view.configure(with: TraceUITabViewModel.defaultConfiguration)
        }
        TraceUISignals.UI.showTraces.listen { _ in
            showTracesList()
        }
        TraceUISignals.UI.showTraceDetail.listen { newTrace in
            self.trace = newTrace
            let viewModel = TraceUITabViewModel(traceName: self.traceName,
                                                showLogsTracesSegmentButton: false,
                                                showLogger: false,
                                                showCloseTraceDetailButton: true,
                                                showStartStopTraceButton: true,
                                                startStopButtonState: .readyToStart,
                                                showSettingsButton: false,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.startTrace.listen { _ in
            let viewModel = TraceUITabViewModel(traceName: self.traceName,
                                                showLogsTracesSegmentButton: false,
                                                showLogger: false,
                                                showCloseTraceDetailButton: false,
                                                showStartStopTraceButton: true,
                                                startStopButtonState: .started,
                                                showSettingsButton: false,
                                                showExportTraceButton: false,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.stopTrace.listen { _ in
            let viewModel = TraceUITabViewModel(traceName: self.traceName,
                                                showLogsTracesSegmentButton: false,
                                                showLogger: false,
                                                showCloseTraceDetailButton: true,
                                                showStartStopTraceButton: true,
                                                startStopButtonState: .stopped,
                                                showSettingsButton: false,
                                                showExportTraceButton: true,
                                                showCollapseUIToolButton: true)
            self.view.configure(with: viewModel)
        }
        TraceUISignals.UI.closeTraceDetail.listen { _ in
            showTracesList()
        }
    }
    
}
