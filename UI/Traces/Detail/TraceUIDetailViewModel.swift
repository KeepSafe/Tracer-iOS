//
//  TraceUIDetailViewModel.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

struct TraceUIDetailViewModel: ViewModeling {
    let trace: Traceable
    let isTraceRunning: Bool
    let statesForItemsToMatch: [TraceItemStateDictionary]
}
