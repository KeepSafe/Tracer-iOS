//
//  TraceUIColors.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

extension UIColor {
    struct TraceUI {
        static let darkBlueGray = UIColor(red: 69/255, green: 80/255, blue: 91/255, alpha: 1)
        static let blueGray = UIColor(red: 99/255, green: 115/255, blue: 129/255, alpha: 1)
        static let lightGray = UIColor(white: 0.95, alpha: 1)
        
        struct StatusButton {
            static let blueGray = UIColor.TraceUI.blueGray
            static let green = UIColor(red: 80/255, green: 184/255, blue: 60/255, alpha: 1)
            static let red = UIColor(red: 191/255, green: 7/255, blue: 17/255, alpha: 1)
            static let yellow = UIColor(red: 237/255, green: 194/255, blue: 0/255, alpha: 1)
            static let shadow = UIColor(white: 0, alpha: 0.25)
        }
    }
}
