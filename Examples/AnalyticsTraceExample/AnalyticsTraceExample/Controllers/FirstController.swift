//
//  FirstController.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class FirstController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset any traces we may have started
        print("\n\n--> RESETTING EXAMPLE TRACES; ignore any failures here since it's just for the example flows")
        Tracers.analytics.stop()
    }

    @IBAction func startSignupFlow() {
        Tracers.analytics.start(trace: .signupFlow)
        Analytics.log(event: .firstViewSeen)
    }
    
    @IBAction func startAssertFlow() {
        Tracers.analytics.start(trace: .assertFlow)
        Analytics.log(event: .firstViewSeen)
    }

}

