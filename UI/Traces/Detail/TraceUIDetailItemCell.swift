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
    
    // MARK: - Instantiation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    // MARK: - API
    
    func configure(with traceItem: TraceItem, isTraceRunning: Bool, state: TraceItemState) {
        UIView.transition(with: contentView, duration: 0.2, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.statusLabel.text = isTraceRunning ? state.emoji : ""
            self.itemLabel.text = "\(traceItem.type.capitalized): \(String(describing: traceItem.itemToMatch))"
            if let uxHint = traceItem.uxFlowHint {
                self.uxHintLabel.text = "UX flow: \(uxHint)"
            }
            self.updateUXHintHeight()
        }, completion: nil)
    }
    
    // MARK: - Private Properties
    
    private let labelFont = UIFont.systemFont(ofSize: 16)
    private let labelHeight: CGFloat = 20
    
    private lazy var statusLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.font = labelFont
        return label
    }()
    
    private lazy var itemLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.font = labelFont
        return label
    }()
    
    private lazy var uxHintLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.font = labelFont
        label.textColor = .lightGray
        return label
    }()
    
    private var uxHintLabelTopAnchor: NSLayoutConstraint?
    private var uxHintLabelHeightAnchor: NSLayoutConstraint?
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private API

private extension TraceUIDetailItemCell {
    
    func setupView() {
        selectionStyle = .none
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        uxHintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(statusLabel)
        contentView.addSubview(itemLabel)
        contentView.addSubview(uxHintLabel)
        
        NSLayoutConstraint.activate([statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
                                     statusLabel.heightAnchor.constraint(equalToConstant: labelHeight),
                                     statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInset.left),
                                     statusLabel.widthAnchor.constraint(equalToConstant: 25)])
        
        NSLayoutConstraint.activate([itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
                                     itemLabel.heightAnchor.constraint(equalToConstant: labelHeight),
                                     itemLabel.leftAnchor.constraint(equalTo: statusLabel.rightAnchor, constant: 5),
                                     itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)])
        
        
        let uxTop = uxHintLabel.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 5)
        let uxHeight = uxHintLabel.heightAnchor.constraint(equalToConstant: labelHeight)
        NSLayoutConstraint.activate([uxTop, uxHeight,
                                     uxHintLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                                     uxHintLabel.leftAnchor.constraint(equalTo: itemLabel.leftAnchor),
                                     uxHintLabel.trailingAnchor.constraint(equalTo: itemLabel.trailingAnchor)])
        uxHintLabelTopAnchor = uxTop
        uxHintLabelHeightAnchor = uxHeight
    }
    
    func updateUXHintHeight() {
        guard let top = uxHintLabelTopAnchor, let height = uxHintLabelHeightAnchor else { return }
        let hasText = uxHintLabel.text != nil && uxHintLabel.text?.isEmpty == false
        top.constant = hasText ? 5 : 0
        height.constant = hasText ? labelHeight : 0
        uxHintLabel.setNeedsLayout()
    }
    
}

// MARK: - TraceItemState

private extension TraceItemState {
    var emoji: String {
        switch self {
        case .waitingToBeMatched: return "⏳"
        case .matched: return "✅"
        case .hadDuplicates, .missing, .outOfOrder: return "❌"
        default: return ""
        }
    }
}
