//
//  TraceResult.swift
//  Tracer
//
//  Created by Rob Phillips on 4/30/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public struct TraceResult {
    
    internal init(trace: Traceable) {
        guard trace.itemsToMatch.isEmpty == false else {
            fatalError("TRACER: Cannot match against an empty array of items. This trace is invalid.")
        }
        
        self.trace = trace
        self.itemsToMatch = trace.itemsToMatch
    }
    
    // MARK: - API
    
    func handleFiring(of item: AnyTraceEquatable) {
        
    }
    
    func finalize() {
        
    }
    
    // MARK: - Properties
    
    let trace: Traceable
    
    let itemsToMatch: [TraceItem]
    
    public fileprivate(set) var wasSuccessful = false
    
    fileprivate(set) var itemsWaitingToBeMatched = [TraceItem]()
    
    fileprivate(set) var itemsMatchedInOrder = [TraceItem]()
    
    fileprivate(set) var itemsMissing = [TraceItem]()
    
    fileprivate(set) var itemsOutOfOrder = [TraceItem]()
    
    fileprivate(set) var matchableItemsFoundDuringTrace = [TraceItem]()
    
    fileprivate(set) var allItemsLoggedDuringTrace = [TraceItem]()
    
}
