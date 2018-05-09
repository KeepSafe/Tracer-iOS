//
//  TraceUI.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// Coordinator for the Trace UI
public final class TraceUI {
    
    // MARK: - Instantiation
    
    /// Prepares UI for display and restores any state
    public init() {
        self.logger = ItemLogger()
        self.loggerListView = ItemLoggerListView()
        self.loggerListPresenter = ItemLoggerListPresenter(view: self.loggerListView)
        
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
    ///
    /// Traces should only be started using the UI
    /// (or manually if using them in other ways outside of this UI tool)
    public func add(traces: [Traceable]) {
        TraceUISignals.Traces.added.fire(data: traces)
    }
    
    /// Logs a generic item to the in-memory tailing log (i.e. this is not for trace logging)
    ///
    /// - Parameters:
    ///   - item: The `AnyTraceEquatable` item to log
    ///   - properties: An optional dictionary of properties (i.e. `LoggedItemProperties`) to log along with this item
    public func log(item: AnyTraceEquatable, properties: LoggedItemProperties? = nil) {
        let loggedItem = LoggedItem(item: item, properties: properties)
        logger.log(item: loggedItem)
        TraceUISignals.Logger.itemLogged.fire(data: loggedItem)
    }
    
    /// Clears the tailing log
    public func clearLog() {
        logger.clear()
    }
    
    // MARK: - Temporary API
    
    public func show(in viewController: UIViewController) {
        setupLoggerView(in: viewController)
        setupTracesList(in: viewController)
        setupTraceDetail(in: viewController)
        
        showLoggerView()
    }
    
    // MARK: - Properties
    
    var loggedItems: [LoggedItem] {
        return logger.loggedItems
    }
    
    // MARK: - Private Properties
    
    private let logger: ItemLogger
    private let loggerListView: ItemLoggerListView
    private let loggerListPresenter: ItemLoggerListPresenter
    
    private let traceListView: TraceUIListView
    private let traceListPresenter: TraceUIListPresenter
    
    private let traceDetailView: TraceUIDetailView
    private let traceDetailPresenter: TraceUIDetailPresenter
    
}

// MARK: - Listeners

private extension TraceUI {
    
    func listenForRoutingActions() {
        TraceUISignals.Traces.showDetail.listen { _ in
            self.showTraceDetail()
        }
    }
    
    func listenForTraceChanges() {
        
    }
    
}

// MARK: - Coordination

private extension TraceUI {
    
    func showLoggerView() {
        display(viewToDisplay: loggerListView, andHide: [traceListView, traceDetailView])
    }
    
    func showTraceList() {
        display(viewToDisplay: traceListView, andHide: [loggerListView, traceDetailView])
    }
    
    func showTraceDetail() {
        display(viewToDisplay: traceDetailView, andHide: [loggerListView, traceListView])
    }
    
    func display(viewToDisplay: UIView, andHide viewsToHide: [UIView]) {
        UIView.animate(withDuration: 0.2, animations: {
            for viewToHide in viewsToHide {
                viewToHide.alpha = 0
            }
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                viewToDisplay.alpha = 1
            })
        })
    }
}

// MARK: - View Setup

private extension TraceUI {
    
    func setupLoggerView(in viewController: UIViewController) {
        setup(view: loggerListView, in: viewController)
    }
    
    func setupTracesList(in viewController: UIViewController) {
        setup(view: traceListView, in: viewController)
    }
    
    func setupTraceDetail(in viewController: UIViewController) {
        setup(view: traceDetailView, in: viewController)
    }
    
    func setup(view: UIView, in viewController: UIViewController) {
        guard let superview = viewController.view else { return }
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
        
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: superview.topAnchor),
                                     view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
}
