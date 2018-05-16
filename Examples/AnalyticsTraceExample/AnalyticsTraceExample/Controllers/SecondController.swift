//
//  SecondController.swift
//  AnalyticsTraceExample
//
//  Created by Rob Phillips on 5/3/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

class SecondController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.log(event: .secondViewSeen)
    }
    
}
