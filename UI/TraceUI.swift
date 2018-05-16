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
    
    /// Starts the logger and listens for signals
    ///
    /// Note: UI will be configured the first time `show` is called
    public init() {
        logger = ItemLogger()
        start()
    }
    
    // MARK: - API
    
    /// Shows the TraceUI tool as a standalone window that floats over top of the application window
    public func show() {
        _ = setupView
        TraceUISignals.UI.show.fire(data: nil)
    }
    
    /// Hides the TraceUI tool from the view
    public func hide() {
        TraceUISignals.UI.hide.fire(data: nil)
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
    ///   - verboseLog: An optional item to log verbosely along with the trace item (not used for comparison, just for display)
    ///   - emojiToPrepend: An optional emoji to prepend to the generic log entry, defaulting to ⚡️
    ///                     (i.e. the emoji does not affect trace item values)
    ///
    /// Note: If no trace is running, this will just log to the generic log and be a no-op
    public func log(traceItem: TraceItem, verboseLog: AnyTraceEquatable? = nil, emojiToPrepend: String? = "⚡️") {
        TraceUISignals.Traces.itemLogged.fire(data: traceItem)
        
        var properties = ["isTraceItem": AnyTraceEquatable(true),
                          "type": AnyTraceEquatable(traceItem.type)]
        if let verboseLog = verboseLog {
            properties["verbose"] = verboseLog
        }
        if let uxFlowHint = traceItem.uxFlowHint {
            properties["uxFlowHint"] = AnyTraceEquatable(uxFlowHint)
        }
        log(genericItem: traceItem.itemToMatch, properties: properties, emojiToPrepend: emojiToPrepend)
    }
    
    /// Logs a verbose `TraceItem` to a trace, if running, and also logs it to the generic log as a
    /// properties type display with a smaller font.
    ///
    /// This is a convenience helper for logging items like dictionaries that may be very verbose
    /// and be more readable when displayed as a properties type.
    ///
    /// - Parameters:
    ///   - traceItem: The `TraceItem` to log
    ///   - emojiToPrepend: An optional emoji to prepend to the generic log entry, defaulting to ⚡️
    ///                     (i.e. the emoji does not affect trace item values)
    ///
    /// Note: If no trace is running, this will just log to the generic log and be a no-op
    public func logVerbose(traceItem: TraceItem, emojiToPrepend: String? = "⚡️") {
        TraceUISignals.Traces.itemLogged.fire(data: traceItem)
        
        var properties = ["isTraceItem": AnyTraceEquatable(true),
                          "traceItem": traceItem.itemToMatch]
        if let uxFlowHint = traceItem.uxFlowHint {
            properties["uxFlowHint"] = AnyTraceEquatable(uxFlowHint)
        }
        log(genericItem: AnyTraceEquatable(traceItem.type), properties: properties, emojiToPrepend: emojiToPrepend)
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
    
    // MARK: - Properties
    
    /// The items logged to the generic tailing log
    public var loggedItems: [LoggedItem] {
        return logger.loggedItems
    }
    
    // MARK: - Private Properties
    
    private let logger: ItemLogger
    private var container: TraceUIContainer?
    private var containerPresenter: TraceUIContainerPresenter?
    
    private lazy var setupView: Void = { [unowned self] in
        let traceUIContainer = TraceUIContainer()
        container = traceUIContainer
        containerPresenter = TraceUIContainerPresenter(view: traceUIContainer)
    }()
    
}

// MARK: - Listeners

private extension TraceUI {
    
    func start() {
        logger.start()
        listenForChanges()
    }
    
    func listenForChanges() {
        TraceUISignals.UI.clearLog.listen { _ in
            self.clearLog()
        }
        
        TraceUISignals.UI.traceReportExported.listen { report in
            guard let (summaryURL, rawLogURL) = report.exportedAsTextFiles(),
                let genericLogURL = ItemLoggerReport(loggedItems: self.loggedItems).exportedAsCSVFile(),
                let rootVC = self.container?.rootViewController
                else { return }
            
            TraceShareSheet.present(with: [summaryURL, rawLogURL, genericLogURL], in: rootVC, success: {
                self.log(genericItem: AnyTraceEquatable("Trace results exported successfully!"))
            }, failure: { error in
                self.log(genericItem: AnyTraceEquatable("Error while exporting trace results: \(error.localizedDescription)"))
            })
        }
        
        TraceUISignals.UI.exportLog.listen { _ in
            guard let rootVC = self.container?.rootViewController,
                let genericLogURL = ItemLoggerReport(loggedItems: self.loggedItems).exportedAsCSVFile()
                else { return }
            TraceShareSheet.present(with: [genericLogURL], in: rootVC, success: {
                self.log(genericItem: AnyTraceEquatable("Logged items exported successfully!"))
            }, failure: { error in
                self.log(genericItem: AnyTraceEquatable("Error while exporting logged items: \(error.localizedDescription)"))
            })
        }
    }
    
}

