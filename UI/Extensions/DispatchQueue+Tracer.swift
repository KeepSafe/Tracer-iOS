//
//  DispatchQueue+Tracer.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func inMain(after seconds: Double, work: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
}
