//
//  ThirdController.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class ThirdController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.log(event: .thirdViewSeen)
        
        print("\n\n---> Trace stopped.")
        guard var report = Tracers.analytics.stop() else {
            assertionFailure("Oops, programming error somewhere.")
            return
        }
        
        print(report.summary)
        print(report.rawLog)
    }
    
}
