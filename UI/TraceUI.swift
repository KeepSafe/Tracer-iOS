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
        self.tabView = TraceUITabView()
        self.tabViewPresenter = TraceUITabPresenter(view: self.tabView)
        
        self.logger = ItemLogger()
        self.logger.start()
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
    
    /// Logs the given `TraceItem` to a trace, if running, and also logs it to the generic log
    ///
    /// - Parameters:
    ///   - traceItem: The `TraceItem` to log
    ///   - emojiToPrepend: An optional emoji to prepend to the generic log entry, defaulting to ⚡️
    ///                     (i.e. the emoji does not affect trace item values)
    ///
    /// Note: If no trace is running, this will just log to the generic log and be a no-op
    public func log(traceItem: TraceItem, emojiToPrepend: String? = "⚡️") {
        TraceUISignals.Traces.itemLogged.fire(data: traceItem)
        
        var properties = ["traceItem": AnyTraceEquatable(true),
                          "type": AnyTraceEquatable(traceItem.type)]
        if let uxFlowHint = traceItem.uxFlowHint {
            properties["uxFlowHint"] = AnyTraceEquatable(uxFlowHint)
        }
        log(genericItem: traceItem.itemToMatch, properties: properties, emojiToPrepend: emojiToPrepend)
    }
    
    /// Logs an item to the in-memory tailing log
    ///
    /// i.e. this is a generic logger used throughout the entire app session
    ///      regardless of whether or not a trace is running
    ///
    /// - Parameters:
    ///   - genericItem: The `AnyTraceEquatable` item to log
    ///   - properties: An optional dictionary of properties (i.e. `LoggedItemProperties`) to log along with this item
    ///   - emojiToPrepend: An optional emoji to prepend to the generic log entry, defaulting to ⚡️
    ///
    /// Note: this isn't used for traces because trace items require a `type` to differentiate
    ///       the items from each other (e.g. ["type": "userId"] with a value of "1" is
    ///       different than ["type": "age"] with a value of "1")
    public func log(genericItem: AnyTraceEquatable, properties: LoggedItemProperties? = nil, emojiToPrepend: String? = "⚡️") {
        let loggedItem: LoggedItem
        if let emojiToPrepend = emojiToPrepend {
            loggedItem = LoggedItem(item: AnyTraceEquatable("\(emojiToPrepend) \(genericItem)"), properties: properties)
        } else {
            loggedItem = LoggedItem(item: genericItem, properties: properties)
        }
        logger.log(item: loggedItem)
        TraceUISignals.Logger.itemLogged.fire(data: loggedItem)
    }
    
    /// Clears the tailing log
    public func clearLog() {
        logger.clear()
    }
    
    // MARK: - Temporary API
    
    public func show(in viewController: UIViewController) {
        setupTabView(in: viewController)
        setupLoggerView(in: viewController)
        setupTracesList(in: viewController)
        setupTraceDetail(in: viewController)
        
        showLoggerView()
    }
    
    // MARK: - Properties
    
    var loggedItems: [LoggedItem] {
        return logger.loggedItems
    }
    
    struct Animation {
        static let duration: Double = 0.25
    }
    
    // MARK: - Private Properties
    
    private let tabView: TraceUITabView
    private let tabViewPresenter: TraceUITabPresenter
    
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
        TraceUISignals.UI.showLogger.listen { _ in
            self.showLoggerView()
        }
        
        TraceUISignals.UI.showTraces.listen { _ in
            self.showTraceList()
        }
        
        TraceUISignals.UI.showTraceDetail.listen { _ in
            self.showTraceDetail()
        }
        
        TraceUISignals.UI.traceReportExported.listen { report in
            guard let (summaryURL, rawLogURL) = report.exportedAsTextFiles(),
                  let genericLogURL = ItemLoggerReport(loggedItems: self.logger.loggedItems).exportedAsTextFile(),
                  let rootVC = UIApplication.shared.keyWindow?.rootViewController
                else { return }
            
            TraceShareSheet.present(with: [summaryURL, rawLogURL, genericLogURL], in: rootVC, success: {
                self.log(genericItem: AnyTraceEquatable("Trace results exported successfully!"))
            }, failure: { error in
                self.log(genericItem: AnyTraceEquatable("Error while exporting trace results: \(error.localizedDescription)"))
            })
        }
        
        TraceUISignals.UI.closeTraceDetail.listen { _ in
            self.showTraceList()
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
        UIView.animate(withDuration: Animation.duration, animations: {
            for viewToHide in viewsToHide {
                viewToHide.alpha = 0
            }
            viewToDisplay.alpha = 1
        })
    }
}

// MARK: - View Setup

private extension TraceUI {
    
    func setupTabView(in viewController: UIViewController) {
        guard let superview = viewController.view else { return }
        tabView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(tabView)
        
        NSLayoutConstraint.activate([tabView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 20),
                                     tabView.heightAnchor.constraint(equalToConstant: TraceUITabView.height),
                                     tabView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     tabView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
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
        
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: tabView.bottomAnchor),
                                     view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
}
