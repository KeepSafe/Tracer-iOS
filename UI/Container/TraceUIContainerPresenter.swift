//
//  TraceUIContainerPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/16/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIContainerPresenter: Presenting {
    
    // MARK: - Instantiation
    
    init(view: TraceUIContainer) {
        self.view = view
        
        listenForRoutingActions()
        listenForTraceChanges()
        listenForUIChanges()
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIContainer
}

// MARK: - Private API

private extension TraceUIContainerPresenter {
    
    func listenForRoutingActions() {
        TraceUISignals.UI.showSettings.listen { _ in
            guard let rootVC = self.view.rootViewController else { return }
            rootVC.present(self.view.traceUIView.settingsActionSheet, animated: true, completion: nil)
        }
        
        TraceUISignals.UI.collapseTool.listen { _ in
            self.view.collapse()
        }
        
        TraceUISignals.UI.expandTool.listen { _ in
            self.view.expand()
        }
        
        TraceUISignals.UI.showSplitView.listen { _ in
            self.view.setupSplitView()
        }
    }
    
    func listenForTraceChanges() {
        TraceUISignals.Traces.stateChanged.listen { traceState in
            self.view.configureStatusButton(state: traceState)
        }
        TraceUISignals.Traces.started.listen { _ in
            self.view.configureStatusButton(state: .waiting)
        }
        TraceUISignals.Traces.stopped.listen { _ in
            self.view.configureStatusButton(state: nil)
        }
    }
    
    func listenForUIChanges() {
        TraceUISignals.UI.statusButtonDragged.listen { tuple in
            self.view.handleButtonDrag(with: tuple.touchPoint, gestureState: tuple.gestureState)
        }
    }
    
}
