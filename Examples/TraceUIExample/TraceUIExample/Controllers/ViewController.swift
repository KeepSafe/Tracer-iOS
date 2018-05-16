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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        runExamples()
    }
    
    // MARK: - Actions
    
    @IBAction func event1Tapped() {
        traceUI.log(traceItem: Event.one.toTraceItem)
    }
    
    @IBAction func event2Tapped() {
        traceUI.log(traceItem: Event.two.toTraceItem)
    }
    
    @IBAction func event3Tapped() {
        traceUI.log(traceItem: Event.three.toTraceItem)
    }
    
    // MARK: - Private Properties
    
    private let traceUI = TraceUI()
    
}

// MARK: - Private API

private extension ViewController {
    
    func runExamples() {
        // Show the UI tool in a window over top of the app
        traceUI.show()

        // Adding some traces to the UI tool
        traceUI.add(traces: EventTrace.allTraces)

        // Example of logging some items
        for i in 1...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i / 10)) {
                let dictionary = ["myAwesomeKey": "someAmazingValue"]
                self.traceUI.log(genericItem: AnyTraceEquatable("Logged a number! It was \(i)"),
                                 properties: ["example": AnyTraceEquatable(dictionary)])
            }
        }

        // Example of adding extra actions to the settings
        let mooLikeACow = UIAlertAction(title: "Moo like a cow", style: .default) { _ in
            self.traceUI.log(genericItem: AnyTraceEquatable("Moooooooooo"), emojiToPrepend: "🐄")
        }
        traceUI.add(settings: [mooLikeACow])
    }

    func mooLikeACow() {
        self.traceUI.log(genericItem: AnyTraceEquatable("Moooooooooo"), emojiToPrepend: "🐄")
    }
    
}

