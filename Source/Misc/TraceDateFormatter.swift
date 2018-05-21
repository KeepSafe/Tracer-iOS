//
//  TraceDateFormatter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

struct TraceDateFormatter {
    // E.g. May 3, 2018 at 12:23:53 PM
    static let `default`: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy 'at' HH:mm:ss a"
        formatter.locale = Locale.current
        return formatter
    }()
}
