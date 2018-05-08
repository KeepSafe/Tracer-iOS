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
        
        self.traceDetailView = TraceUIDetailView()
        self.traceDetailPresenter = TraceUIDetailPresenter(view: self.traceDetailView)
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
    
    public func show(in viewController: UIViewController) {
        setupTracesList(in: viewController)
        setupTraceDetail(in: viewController)
        showTraceList()
    }
    
    // MARK: - Private Properties
    
    private let traceListView: TraceUIListView
    private let traceListPresenter: TraceUIListPresenter
    
    private let traceDetailView: TraceUIDetailView
    private let traceDetailPresenter: TraceUIDetailPresenter
    
}

// MARK: - Listeners

private extension TraceUICoordinator {
    
    func listenForRoutingActions() {
        TraceUISignals.Traces.showDetail.listen { _ in
            self.showTraceDetail()
        }
    }
    
    func listenForTraceChanges() {
        
    }
    
}

// MARK: - Coordination

private extension TraceUICoordinator {
    
    func showTraceList() {
        display(viewToDisplay: traceListView, andHide: traceDetailView)
    }
    
    func showTraceDetail() {
        display(viewToDisplay: traceDetailView, andHide: traceListView)
    }
    
    func display(viewToDisplay: UIView, andHide viewToHide: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            viewToHide.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                viewToDisplay.alpha = 1
            })
        })
    }
}

// MARK: - View Setup

private extension TraceUICoordinator {
    
    func setupTracesList(in viewController: UIViewController) {
        guard let superview = viewController.view else { return }
        traceListView.alpha = 0
        traceListView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(traceListView)
        
        NSLayoutConstraint.activate([traceListView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     traceListView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     traceListView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     traceListView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
    func setupTraceDetail(in viewController: UIViewController) {
        guard let superview = viewController.view else { return }
        traceDetailView.alpha = 0
        traceDetailView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(traceDetailView)
        
        NSLayoutConstraint.activate([traceDetailView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     traceDetailView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     traceDetailView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     traceDetailView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
}
