//
//  TraceUIDetailItemCell.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIDetailItemCell: UITableViewCell, Viewing {
    static let identifier = "\(TraceUIDetailItemCell.self)"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(with traceItem: TraceItem) {
        selectionStyle = .none
        textLabel?.text = "\(traceItem.type.capitalized): \(String(describing: traceItem.itemToMatch))"
        if let uxHint = traceItem.uxFlowHint {
            detailTextLabel?.text = "UX flow: \(uxHint)"
        } else {
            detailTextLabel?.text = nil
        }
        detailTextLabel?.font = .systemFont(ofSize: 16)
        detailTextLabel?.textColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
