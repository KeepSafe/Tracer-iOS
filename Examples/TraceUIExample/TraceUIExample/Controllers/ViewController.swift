//
//  ViewController.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        App.traceUICoordinator.show(in: self)
        App.traceUICoordinator.add(traces: EventTrace.allTraces)
    }
    
}

