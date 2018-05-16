//
//  TraceUIViewModel.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

enum TraceUIViewName {
    case loggerList, traceList, traceDetail
}

struct TraceUIViewModel: ViewModeling {
    let viewName: TraceUIViewName
}
