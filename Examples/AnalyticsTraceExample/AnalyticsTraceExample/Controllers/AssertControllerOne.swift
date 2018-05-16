//
//  AssertControllerOne.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/4/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class AssertControllerOne: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fire the wrong event here (.secondViewSeen should be fired)
        // and it will assert because it caused the trace to fail
        Analytics.log(event: .thirdViewSeen)
    }
    
}
