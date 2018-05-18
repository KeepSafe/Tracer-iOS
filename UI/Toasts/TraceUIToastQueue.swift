//
//  TraceUIToastQueue.swift
//  Tracer
//
//  Created by Rob Phillips on 5/18/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUIToastQueue {
    
    // MARK: - Instantiation
    
    init() {}
    
    // MARK: - API
    
    func queue(toast: TraceUIToast) {
        queue.addOperation(toast)
    }
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
    // MARK: - Private Properties
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
