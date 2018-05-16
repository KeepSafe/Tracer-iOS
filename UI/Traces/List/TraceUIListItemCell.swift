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
    static let height: CGFloat = 60
    
    // MARK: - Instantiation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    // MARK: - Overrides
    
    public override func prepareForReuse() {
        nameLabel.text = nil
    }
    
    // MARK: - API
    
    func configure(with trace: Traceable) {
        accessoryType = .disclosureIndicator
        nameLabel.text = trace.name
    }
    
    // MARK: - Private Properties
    
    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIListItemCell {
    
    func setupView() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: TraceUIListItemCell.height)])
        
        NSLayoutConstraint.activate([nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                                     nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
                                     nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInset.left),
                                     nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)])
    }
    
}
