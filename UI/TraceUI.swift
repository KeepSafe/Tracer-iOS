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
    
    struct Animation {
        static let duration: Double = 0.25
    }
    
    // MARK: - Instantiation
    
    /// Prepares UI for display and restores any state
    public init() {
        logger = ItemLogger()
        
        statusButton = TraceStatusButton()
        container = TraceUIView()
        containerPresenter = TraceUIPresenter(view: container)
        splitView = TraceUISplitView(resizableView: container)
        window = TraceUIWindow(rootViewController: splitView)
        
        start()
    }
    
    // MARK: - API
    
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
    
    public func show() {
        setupSplitView()
    }
    
    // MARK: - Properties
    
    /// The items logged to the generic tailing log
    public var loggedItems: [LoggedItem] {
        return logger.loggedItems
    }
    
    // MARK: - Private Properties
    
    private let logger: ItemLogger
    
    private let window: TraceUIWindow
    
    private let statusButton: TraceStatusButton
    private let splitView: TraceUISplitView
    private let container: TraceUIView
    private let containerPresenter: TraceUIPresenter
    
    private var rootViewController: UIViewController? {
        return splitView // TODO for fixed views: UIApplication.shared.keyWindow?.rootViewController
    }
    
    private let statusButtonPadding: CGFloat = 5
    private var statusButtonLeftConstraint: NSLayoutConstraint?
    private var statusButtonTopConstraint: NSLayoutConstraint?
    
    private let defaultsStore = UserDefaults.standard
    private let lastStatusButtonDragPointKey = "traceUI.lastStatusButtonDragPointKey"
    
    private var savedStatusButtonPoint: CGPoint? {
        guard let pointString = defaultsStore.value(forKey: lastStatusButtonDragPointKey) as? String else { return nil }
        return CGPointFromString(pointString)
    }
}

// MARK: - Listeners

private extension TraceUI {
    
    /// Starts listening for changes
    func start() {
        logger.start()
        listenForRoutingActions()
        listenForTraceChanges()
        listenForUIChanges()
    }
    
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
        
        TraceUISignals.UI.collapseTool.listen { _ in
            self.collapse()
        }
        
        TraceUISignals.UI.expandTool.listen { _ in
            self.expand()
        }
    }
    
    func listenForTraceChanges() {
        TraceUISignals.Traces.stateChanged.listen { traceState in
            self.statusButton.configure(with: traceState)
        }
        TraceUISignals.Traces.started.listen { _ in
            self.statusButton.configure(with: .waiting)
        }
        TraceUISignals.Traces.stopped.listen { _ in
            self.statusButton.configure(with: nil)
        }
    }
    
    func listenForUIChanges() {
        TraceUISignals.UI.statusButtonDragged.listen { tuple in
            self.handleButtonDrag(with: tuple.touchPoint, gestureState: tuple.gestureState)
        }
    }
    
}

// MARK: - Private API

private extension TraceUI {
    
    // MARK: - View Setup
    
    func setupFixedSize() {
        setup(view: container)
    }
    
    func setupSplitView() {
        setup(view: splitView.view)
        splitView.view.alpha = 0
        setupStatusButton()
    }
    
    func setup(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        window.addSubview(view)
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: window.topAnchor),
                                     view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: window.trailingAnchor)])
    }
    
    func setupStatusButton() {
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(statusButton)
    
        let buttonPoint: CGPoint
        if let savedButtonPoint = savedStatusButtonPoint {
            buttonPoint = savedButtonPoint
        } else {
            let topOffset = UIScreen.main.bounds.size.height - TraceStatusButton.sizeLength - statusButtonPadding * 2
            let leftOffset = statusButtonPadding * 2
            buttonPoint = CGPoint(x: leftOffset, y: topOffset)
        }
        
        let topConstraint = statusButton.topAnchor.constraint(equalTo: window.topAnchor, constant: buttonPoint.y)
        statusButtonTopConstraint = topConstraint
        let leftConstraint = statusButton.leftAnchor.constraint(equalTo: window.leftAnchor, constant: buttonPoint.x)
        statusButtonLeftConstraint = leftConstraint
        
        NSLayoutConstraint.activate([topConstraint,
                                     leftConstraint,
                                     statusButton.heightAnchor.constraint(equalToConstant: TraceStatusButton.sizeLength),
                                     statusButton.widthAnchor.constraint(equalToConstant: TraceStatusButton.sizeLength)])
    }
    
    // MARK: - Animations
    
    func collapse() {
        let animator = TraceUIRevealAnimator(isExpanding: false, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    func expand() {
        let animator = TraceUIRevealAnimator(isExpanding: true, triggeringButton: statusButton, expandableView: splitView.view)
        animator.start()
    }
    
    // MARK: - Dragging
    
    func handleButtonDrag(with buttonDragTouchPoint: CGPoint, gestureState: UIGestureRecognizerState? = nil) {
        let touchPoint = window.convert(buttonDragTouchPoint, from: self.statusButton)
        
        // Can't go off left or right edge
        var newLeftConstant = touchPoint.x - TraceStatusButton.sizeLength / 2
        newLeftConstant = max(newLeftConstant, 0 + statusButtonPadding)
        newLeftConstant = min(newLeftConstant, UIScreen.main.bounds.size.width - TraceStatusButton.sizeLength - statusButtonPadding)
        
        // Can't go off top or bottom edge
        var newTopConstant = touchPoint.y - TraceStatusButton.sizeLength / 2
        let statusBarHeight: CGFloat = 20
        newTopConstant = max(newTopConstant, 0 + statusButtonPadding + statusBarHeight)
        newTopConstant = min(newTopConstant, UIScreen.main.bounds.size.height - TraceStatusButton.sizeLength - statusButtonPadding)
        
        let newPoint = CGPoint(x: newLeftConstant, y: newTopConstant)
        
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.statusButtonLeftConstraint?.constant = newPoint.x
            self.statusButtonTopConstraint?.constant = newPoint.y
            self.window.layoutIfNeeded()
        }, completion: nil)
        
        if gestureState == .ended {
            defaultsStore.set(NSStringFromCGPoint(newPoint), forKey: lastStatusButtonDragPointKey)
        }
    }
    
}
