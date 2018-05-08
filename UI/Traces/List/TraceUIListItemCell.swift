//
//  TraceUIListItemCell.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIListItemCell: UITableViewCell, Viewing {
    static let identifier = "\(TraceUIListItemCell.self)"
    
    func configure(with trace: Traceable) {
        accessoryType = .disclosureIndicator
        textLabel?.text = trace.name
    }
}
