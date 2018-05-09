//
//  ViewController.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit
import Tracer

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show the UI tool in this controller
        App.traceUI.show(in: self)
        
        // Adding some traces to the UI tool
        App.traceUI.add(traces: EventTrace.allTraces)
        
        // Example of logging some items
        for i in 1...50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i / 10)) {
                let dictionary = ["myAwesomeKey": "someAmazingValue"]
                App.traceUI.log(item: AnyTraceEquatable("⚡️ Logged a number! It was \(i)"), properties: ["example": AnyTraceEquatable(dictionary)])
            }
        }
    }
    
}

