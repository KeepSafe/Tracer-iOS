//
//  TestController.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/21/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TestController: UIViewController {
    
    @IBAction func clearDefaults() {
        // Clear button/view drag locations
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "traceUI.lastStatusButtonDragPointKey")
        defaults.set(nil, forKey: "traceUISplitView.lastTransparentViewHeightKey")
    }
    
}
