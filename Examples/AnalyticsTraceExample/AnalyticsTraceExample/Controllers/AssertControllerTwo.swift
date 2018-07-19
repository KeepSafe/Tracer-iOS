//
//  AssertControllerTwo.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 7/19/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class AssertControllerTwo: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fire the wrong event here (.thirdViewSeen should be fired)
        // and it will assert because it caused the trace to fail
        Analytics.log(event: .firstViewSeen)
    }

}
