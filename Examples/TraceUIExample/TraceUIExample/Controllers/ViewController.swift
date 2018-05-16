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
        
        setupView()
        runExamples()
    }
    
    private let traceUI = TraceUI()
    
}

// MARK: - Private API

private extension ViewController {
    
    func runExamples() {
        // Show the UI tool in a window over top of the app
        traceUI.showFloatingUI()

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
            self.mooLikeACow()
        }
        traceUI.add(settings: [mooLikeACow])

        // TODO: Remove after testing
        for i in 10...17 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                if i == 10 {
                    self.traceUI.log(traceItem: Event.logicCheckpointOne.toTraceItem)
                }
                if i == 13 {
                    self.traceUI.log(traceItem: Event.logicCheckpointTwo.toTraceItem)
                }
                if i == 16 {
                    self.traceUI.log(traceItem: Event.logicCheckpointThree.toTraceItem)
                }
            }
        }
    }

    func mooLikeACow() {
        self.traceUI.log(genericItem: AnyTraceEquatable("Moooooooooo"), emojiToPrepend: "🐄")
    }

    func setupView() {
        view.backgroundColor = .white

        let button = UIButton()
        button.setTitleColor(view.tintColor, for: .normal)
        button.setTitle("Tap me", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)
        NSLayoutConstraint.activate([button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     button.widthAnchor.constraint(equalToConstant: 100),
                                     button.heightAnchor.constraint(equalToConstant: 44)])
    }

    @objc func buttonTapped() {
        mooLikeACow()
    }
}

