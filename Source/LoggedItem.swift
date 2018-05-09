//
//  LoggedItem.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

public struct LoggedItem {
    init(_ item: AnyTraceEquatable) {
        self.item = item
    }
    
    let timestamp = Date()
    let item: AnyTraceEquatable
}
