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
        TraceUISignals.UI.showSettings.listen { button in
            let rootVC = self.view.rootViewController
            let actionSheet = self.view.traceUIView.settingsActionSheet
            actionSheet.popoverPresentationController?.sourceView = button
            rootVC.present(actionSheet, animated: true, completion: nil)
        }
        
        TraceUISignals.UI.collapseTool.listen { _ in
            self.view.collapse()
        }
        
        TraceUISignals.UI.expandTool.listen { _ in
            self.view.expand()
        }
        
        TraceUISignals.UI.show.listen { _ in
            self.view.show()
        }
        
        TraceUISignals.UI.hide.listen { _ in
            self.view.hide()
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
        
        TraceUISignals.Toasts.show.listen { toast in
            self.view.show(toast: toast)
        }
    }
    
}
