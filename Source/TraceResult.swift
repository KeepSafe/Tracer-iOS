//
//  TraceResult.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// Collects and evaluates the results of the trace so they can be summarized later
public struct TraceResult {
    
    /// Orchestrates the logic behind the results of this trace.
    ///
    /// - Parameter trace: The active `Traceable` trace
    internal init(trace: Traceable) {
        guard trace.itemsToMatch.isEmpty == false else {
            fatalError("TRACER: Trace is invalid; cannot match against an empty array of items.")
        }
        
        self.trace = trace
        var matchableItemStates = [[TraceItem: TraceItemState]]()
        trace.itemsToMatch.forEach({ matchableItemStates.append([$0: .waitingToBeMatched]) })
        self.statesForItemsToMatch = matchableItemStates
    }
    
    // MARK: - API
    
    /// Collects and evaluates the given item to see how it impacts the active trace.
    ///
    /// - Parameter item: The `TraceItem` item that was fired
    internal mutating func handleFiring(of item: TraceItem) {
        guard finalized == false else { return }
        categorize(firedItem: item)
    }
    
    /// Finalizes the trace by checking for any missing trace items
    internal mutating func finalize() {
        guard finalized == false else { return }
        while let index = statesForItemsToMatch.index(where: { $0.values.first == .waitingToBeMatched }) {
            guard let item = statesForItemsToMatch[index].keys.first else { continue }
            statesForItemsToMatch[index][item] = .missing
        }
        updateTraceState(finalizing: true)
        finalized = true
    }
    
    // MARK: - Properties
    
    /// The trace for which this result was generated
    public let trace: Traceable
    
    /// A signal that is fired any time the trace's overall state is changed, returning the state
    public let stateChanged = TraceSignal<TraceState>()
    
    /// The trace's `itemsToMatch` with states for how they've been matched during the trace
    public fileprivate(set) var statesForItemsToMatch: [[TraceItem: TraceItemState]]
    
    /// A tailing log of all items 
    public fileprivate(set) var statesForAllLoggedItems = [[TraceItem: TraceItemState]]()
    
    /// The current state of the overall trace
    ///
    /// Note: this will fire the `stateChanged` signal when set
    public fileprivate(set) var state: TraceState = .waiting {
        didSet {
            stateChanged.fire(data: state)
        }
    }
    
    // MARK: - Private Properties
    
    fileprivate var finalized = false
    
}

// MARK: - Private API

fileprivate extension TraceResult {
    
    mutating func categorize(firedItem item: TraceItem) {
        // Update the tailing log and trace state
        func updateLog(with newItem: TraceItem, state: TraceItemState) {
            statesForAllLoggedItems.append([newItem: state])
            updateTraceState()
        }
        
        // Check if we should ignore this item
        if trace.itemsToMatch.contains(item) == false {
            updateLog(with: item, state: .ignoredNoMatch)
            return
        }
        
        // Otherwise, check the item can be matched by finding the first
        // item index of this name that's still waiting to be matched
        if let index = statesForItemsToMatch.index(where: { $0[item] == .waitingToBeMatched }) {
            let itemState: TraceItemState
            if trace.enforceOrder == false {
                itemState = .matched
            } else {
                // Enforcing order, so just compare if this item is expected at this index
                // e.g. if the trace's items are ["a", "b", "c", "d"], this item is "c",
                // and we've already shown it's still "waitingToBeMatched", we'll just consume
                // this item and mark it as matched
                if trace.itemsToMatch[index] == item {
                    itemState = .matched
                } else {
                    itemState = .outOfOrder
                }
            }
            
            statesForItemsToMatch[index][item] = itemState
            updateLog(with: item, state: itemState)
        } else {
            // The item matches one found in items to match, but we've already matched all of its
            // type that we were supposed to, so just log it as ignored
            updateLog(with: item, state: .ignoredButMatched)
        }
    }
    
    mutating func updateTraceState(finalizing: Bool = false) {
        // Once a trace is deemed failing, nothing can change
        // that result without re-running the trace
        guard state != .failed else { return }
        
        // Check for failing states first
        let failedItems: [TraceItem: TraceItemState]?
        if trace.enforceOrder {
            failedItems = statesForItemsToMatch.first(where: { ($0.values.first == .missing) || ($0.values.first == .outOfOrder) })
        } else {
            failedItems = statesForItemsToMatch.first(where: { ($0.values.first == .missing) })
        }
        if failedItems?.isEmpty == false {
            state = .failed
            return
        }
        
        // Check if all items are waiting to be matched
        let allItemsWaitingToBeMatched = statesForItemsToMatch.first(where: { ($0.values.first != .waitingToBeMatched) }) == nil
        if allItemsWaitingToBeMatched {
            return
        }
        
        // Otherwise, check if we're passing so far
        if finalizing {
            let allItemsPassing = statesForItemsToMatch.first(where: { ($0.values.first != .matched) }) == nil
            if allItemsPassing {
                state = .passed
            }
        } else {
            let atleastOneItemPassing = statesForItemsToMatch.first(where: { ($0.values.first == .matched) }) != nil
            if atleastOneItemPassing {
                state = .passing
            }
        }
    }
    
}
