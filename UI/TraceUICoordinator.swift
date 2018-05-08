//
//  TraceUICoordinator.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

public final class TraceUICoordinator {
    
    // MARK: - Instantiation
    
    /// Prepares UI for display and restores any state
    public init() {
        self.traceListView = TraceUIListView()
        self.traceListPresenter = TraceUIListPresenter(view: self.traceListView)
    }
    
    // MARK: - API
    
    /// Starts listening for changes
    public func start() {
        listenForRoutingActions()
        listenForTraceChanges()
    }
    
    /// Adds the traces to the list of executable traces
    public func add(traces: [Traceable]) {
        TraceUISignals.Traces.added.fire(data: traces)
    }
    
    // MARK: - Temporary API
    
    public func showTracesList(in viewController: UIViewController) {
        guard let superview = viewController.view else { return }
        traceListView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(traceListView)
        
        NSLayoutConstraint.activate([traceListView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     traceListView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     traceListView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     traceListView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
    // MARK: - Private Properties
    
    private let traceListView: TraceUIListView
    private let traceListPresenter: TraceUIListPresenter
    
}

// MARK: - Listeners

private extension TraceUICoordinator {
    
    func listenForRoutingActions() {
        TraceUISignals.Traces.showTraceDetail.listen { traceToShow in
            
        }
    }
    
    func listenForTraceChanges() {
        
    }
}
