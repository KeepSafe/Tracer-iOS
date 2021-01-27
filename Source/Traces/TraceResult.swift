//
//  TraceResult.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public typealias TraceItemStateDictionary = [TraceItem: TraceItemState]

/// Collects and evaluates the results of the trace so they can be summarized later
public final class TraceResult {
    
    /// Orchestrates the logic behind the results of this trace.
    ///
    /// - Parameter trace: The active `Traceable` trace
    internal init(trace: Traceable) {
        guard trace.itemsToMatch.isEmpty == false else {
            fatalError("TRACER: Trace is invalid; cannot match against an empty array of items.")
        }
        
        self.trace = trace
        var matchableItemStates = [TraceItemStateDictionary]()
        trace.itemsToMatch.forEach({ matchableItemStates.append([$0: .waitingToBeMatched]) })
        self.statesForItemsToMatch = matchableItemStates
    }
    
    // MARK: - API
    
    /// Collects and evaluates the given item to see how it impacts the active trace.
    ///
    /// - Parameter item: The `TraceItem` item that was fired
    internal func handleFiring(of item: TraceItem) {
        guard finalized == false else { return }
        categorize(firedItem: item)
    }
    
    /// Finalizes the trace by checking for any missing trace items
    internal func finalize() {
        guard finalized == false else { return }
        while let index = statesForItemsToMatch.firstIndex(where: { $0.values.first == .waitingToBeMatched }) {
            guard let item = statesForItemsToMatch[index].keys.first else { continue }
            statesForItemsToMatch[index][item] = .missing
        }
        updateTraceState(finalizing: true)
        endTime = Date()
        finalized = true
    }
    
    // MARK: - Properties
    
    /// The trace for which this result was generated
    public let trace: Traceable
    
    /// A signal that is fired any time the trace's overall state is changed, returning the state
    public let stateChanged = TraceStateChangedSignal()
    
    /// The trace's `itemsToMatch` with states for how they've been matched during the trace
    public fileprivate(set) var statesForItemsToMatch: [TraceItemStateDictionary]
    
    /// A tailing log of all items 
    public fileprivate(set) var statesForAllLoggedItems = [TraceItemStateDictionary]()
    
    /// The current state of the overall trace
    ///
    /// Note: this will fire the `stateChanged` signal when set
    public fileprivate(set) var state: TraceState = .waiting {
        didSet {
            stateChanged.fire(data: state)
            
            if oldValue != .failed && (state == .failed && canThrowAssertions && trace.assertOnFailure) {
                finalize()

                // Print the report to the debug console
                #if DEBUG
                    let report = TraceReport(result: self)
                    print(report.summary)
                    // Optionally, you can print the raw log
                    // to see all events fired during the session
//                    print(report.rawLog)
                #endif

                assertionFailure("Trace (\(trace.name)) failed.")
            }
        }
    }
    
    /// The date and time at which this trace started
    public let startTime = Date()
    
    /// The date and time at which this trace ended
    public fileprivate(set) var endTime: Date?

    /// An override point where the app won't assert on failure; useful for enabling different
    /// behaviors for unit tests versus running the same trace in the UI tool where you may
    /// not want to throw assertions
    public internal(set) var canThrowAssertions = true
    
    // MARK: - Private Properties
    
    fileprivate var finalized = false
    
}

// MARK: - Private API

fileprivate extension TraceResult {
    
    func categorize(firedItem item: TraceItem) {
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
        
        // Otherwise, check the item can be matched by finding the first generic
        // item that's still waiting to be matched and see if it matches
        // the first item of the passed in type that's waiting to be matched
        if let firstGenericIndexWaitingToBeMatched = statesForItemsToMatch.firstIndex(where: { $0.values.first == .waitingToBeMatched }),
           let indexOfThisTypeWaitingToBeMatched = statesForItemsToMatch.firstIndex(where: { $0[item] == .waitingToBeMatched }) {
            let itemState: TraceItemState
            if trace.enforceOrder == false {
                itemState = .matched
            } else {
                // Enforcing order, so just compare if this item is expected at this index
                // e.g. if the trace's items are ["a", "b", "c", "d"], this item is "c",
                // and we've already shown it's still "waitingToBeMatched", we'll just consume
                // this item and mark it as matched
                if trace.itemsToMatch[firstGenericIndexWaitingToBeMatched] == item {
                    itemState = .matched
                } else {
                    itemState = .outOfOrder
                    
                    // If this item is out-of-order, any waiting items before it are also out-of-order
                    let previousItems = statesForItemsToMatch[0..<indexOfThisTypeWaitingToBeMatched]
                    for (index, previousItem) in previousItems.enumerated() {
                        guard previousItem.values.first == .waitingToBeMatched,
                              let previousWaitingItem = previousItem.keys.first else { continue }
                        statesForItemsToMatch[index][previousWaitingItem] = .outOfOrder
                    }
                }
            }
            
            // Update the first instance of this item type waiting to be matched
            statesForItemsToMatch[indexOfThisTypeWaitingToBeMatched][item] = itemState
            updateLog(with: item, state: itemState)
        } else {
            if trace.allowDuplicates {
                // The item matches one found in items to match, but we've already matched all of its
                // type that we were supposed to, so just log it as ignored
                updateLog(with: item, state: .ignoredButMatched)
            } else if let indexOfThisType = statesForItemsToMatch.firstIndex(where: { $0.keys.first == item }) {
                // Fail the overall trace by marking the type it duplicated
                statesForItemsToMatch[indexOfThisType][item] = .hadDuplicates
                
                // Then mark this extraneous item as a duplicate and update trace state
                updateLog(with: item, state: .duplicate)
            }
        }
    }
    
    func updateTraceState(finalizing: Bool = false) {
        // Once a trace is deemed failing, nothing can change
        // that result without re-running the trace
        guard state != .failed else {
            state = .failed
            return
        }
        
        // Check for failing states first
        let failedItems: TraceItemStateDictionary?
        if trace.enforceOrder {
            failedItems = statesForItemsToMatch.first(where: { traceItemStateDictionary -> Bool in
                let traceItemState = traceItemStateDictionary.values.first
                if trace.allowDuplicates {
                    return traceItemState == .missing || traceItemState == .outOfOrder
                } else {
                    return traceItemState == .missing || traceItemState == .outOfOrder || traceItemState == .hadDuplicates
                }
            })
        } else {
            // Not enforcing order
            failedItems = statesForItemsToMatch.first(where: { traceItemStateDictionary -> Bool in
                let traceItemState = traceItemStateDictionary.values.first
                if trace.allowDuplicates {
                    return traceItemState == .missing
                } else {
                    return traceItemState == .missing || traceItemState == .hadDuplicates
                }
            })
        }
        if failedItems?.isEmpty == false {
            state = .failed
            return
        }
        
        // Check if all items are waiting to be matched
        let allItemsWaitingToBeMatched = statesForItemsToMatch.first(where: { ($0.values.first != .waitingToBeMatched) }) == nil
        if allItemsWaitingToBeMatched {
            state = .waiting
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
