//
//  UIImage+Tracer.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

extension UIImage {
    static func inBundle(named name: String) -> UIImage {
        guard let image = UIImage(named: name, in: Bundle(for: TraceUI.self), compatibleWith: nil) else {
            fatalError("Missing an image in the framework")
        }
        return image
    }
}
