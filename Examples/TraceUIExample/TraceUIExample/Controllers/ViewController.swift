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
        
        view.backgroundColor = .red
        
        // Show the UI tool in this controller
        App.traceUI.show(in: self)
        
        // Adding some traces to the UI tool
        App.traceUI.add(traces: EventTrace.allTraces)
        
        // Example of logging some items
        for i in 1...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i / 10)) {
                let dictionary = ["myAwesomeKey": "someAmazingValue"]
                App.traceUI.log(genericItem: AnyTraceEquatable("Logged a number! It was \(i)"),
                                properties: ["example": AnyTraceEquatable(dictionary)])
            }
        }
        
        // Example of adding extra actions to the settings
        let mooLikeACow = UIAlertAction(title: "Moo like a cow", style: .default) { _ in
            App.traceUI.log(genericItem: AnyTraceEquatable("Moooooooooo"), emojiToPrepend: "🐄")
        }
        App.traceUI.add(settings: [mooLikeACow])
        
        // TODO: Remove after testing
        for i in 10...17 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                if i == 10 {
                    App.traceUI.log(traceItem: Event.logicCheckpointOne.toTraceItem)
                }
                if i == 13 {
                    App.traceUI.log(traceItem: Event.logicCheckpointTwo.toTraceItem)
                }
                if i == 16 {
                    App.traceUI.log(traceItem: Event.logicCheckpointThree.toTraceItem)
                }
            }
        }
    }
    
}

