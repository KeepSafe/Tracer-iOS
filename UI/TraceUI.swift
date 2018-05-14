//
//  TraceUI.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// Coordinator for the Trace UI
public final class TraceUI: Listening {
    
    // MARK: - Instantiation
    
    /// Prepares UI for display and restores any state
    public init() {
        self.logger = ItemLogger()
        self.container = TraceUIView()
        self.containerPresenter = TraceUIPresenter(view: self.container)
        self.splitView = TraceUISplitView(resizableView: self.container)
    }
    
    // MARK: - API
    
    /// Starts listening for changes
    public func start() {
        logger.start()
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
    
    /// Optionally add extra settings to the settings action sheet
    ///
    /// - Parameter settings: An array of settings to add
    ///
    /// Note: this is a no-op if a setting with that title already exists
    public func add(settings: [UIAlertAction]) {
        TraceUISignals.UI.settingsAdded.fire(data: settings)
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
        guard let superview = viewController.view else { return }
        showAsSplitView(in: superview)
    }
    
    // MARK: - Properties
    
    /// The items logged to the generic tailing log
    public var loggedItems: [LoggedItem] {
        return logger.loggedItems
    }
    
    struct Animation {
        static let duration: Double = 0.25
    }
    
    // MARK: - Private Properties
    
    private let logger: ItemLogger
    
    private let splitView: TraceUISplitView
    private let container: TraceUIView
    private let containerPresenter: TraceUIPresenter
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}

// MARK: - Listeners

private extension TraceUI {
    
    func listenForRoutingActions() {
        
        TraceUISignals.UI.traceReportExported.listen { report in
            guard let (summaryURL, rawLogURL) = report.exportedAsTextFiles(),
                  let genericLogURL = ItemLoggerReport(loggedItems: self.loggedItems).exportedAsCSVFile(),
                  let rootVC = self.rootViewController
                else { return }
            
            TraceShareSheet.present(with: [summaryURL, rawLogURL, genericLogURL], in: rootVC, success: {
                self.log(genericItem: AnyTraceEquatable("Trace results exported successfully!"))
            }, failure: { error in
                self.log(genericItem: AnyTraceEquatable("Error while exporting trace results: \(error.localizedDescription)"))
            })
        }
        
        TraceUISignals.UI.showSettings.listen { _ in
            guard let rootVC = self.rootViewController else { return }
            rootVC.present(self.container.settingsActionSheet, animated: true, completion: nil)
        }
        
        TraceUISignals.UI.exportLog.listen { _ in
            guard let rootVC = self.rootViewController,
                  let genericLogURL = ItemLoggerReport(loggedItems: self.loggedItems).exportedAsCSVFile()
                else { return }
            TraceShareSheet.present(with: [genericLogURL], in: rootVC, success: {
                self.log(genericItem: AnyTraceEquatable("Logged items exported successfully!"))
            }, failure: { error in
                self.log(genericItem: AnyTraceEquatable("Error while exporting logged items: \(error.localizedDescription)"))
            })
        }
        
        TraceUISignals.UI.clearLog.listen { _ in
            self.clearLog()
        }
    }
    
    func listenForTraceChanges() {
        
    }
    
}

// MARK: - View Setup

private extension TraceUI {
    
    func showAsFixedSize(in superview: UIView) {
        show(view: container, in: superview)
    }
    
    func showAsSplitView(in view: UIView) {
        show(view: splitView, in: view)
    }
    
    func show(view: UIView, in superview: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: superview.topAnchor),
                                     view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
}
