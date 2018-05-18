//
//  Dictionary+AttributedString.swift
//  Tracer
//
//  Created by Rob Phillips on 5/16/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

/// Specifically, this is an extension of LoggedItemProperties which is typed as [String: AnyTraceEquatable]
internal extension Dictionary where Key: ExpressibleByStringLiteral, Value: CustomStringConvertible {
    
    func attributedLoggerDescription(fontSize: CGFloat) -> NSAttributedString {
        let v = NSMutableAttributedString(string: "")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        let boldAttribute: [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph,
                                                           .font: UIFont.boldSystemFont(ofSize: fontSize)]
        for (key, value) in self {
            let boldString = NSAttributedString(string: "\(key)", attributes: boldAttribute)
            v.append(boldString)
            v.append(NSAttributedString(string: ": \(value)\n"))
        }
        return v
    }

}
