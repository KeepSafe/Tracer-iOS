//
//  FirstController.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class FirstController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Tracers.analytics.start(trace: .signupFlow)
        Analytics.log(event: .firstViewSeen)
    }

}

