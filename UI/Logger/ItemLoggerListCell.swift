//
//  ItemLoggerListCell.swift
//  Tracer
//
//  Created by Rob Phillips on 5/9/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class ItemLoggerListCell: UITableViewCell, Viewing {
    
    static let identifier = "\(ItemLoggerListCell.self)"
    
    // MARK: - Instantiation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    // MARK: - API
    
    var loggedItem: LoggedItem? {
        didSet {
            guard let loggedItem = loggedItem else {
                itemLabel.text = nil
                timestampLabel.text = nil
                propertiesLabel.text = nil
                return
            }
            
            itemLabel.text = String(describing: loggedItem.item)
            timestampLabel.text = dateFormatter.string(from: loggedItem.timestamp)
            propertiesLabel.text = loggedItem.properties?.loggerDescription
        }
    }
    
    // MARK: - Overrides
    
    override func prepareForReuse() {
        loggedItem = nil
    }
    
    // MARK: - Private View Properties
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 10.0)
        return label
    }()
    
    private lazy var itemLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14.0)
        return label
    }()
    
    private lazy var propertiesLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.0)
        return label
    }()
    
    // E.g. May 3, 2018 at 12:23:53 PM
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy 'at' HH:mm:ss a"
        formatter.locale = Locale.current
        return formatter
    }()
    
    // MARK: - Unsupported Initializers
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension ItemLoggerListCell {
    
    func setupView() {
        selectionStyle = .none
        accessoryType = .none
        
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        propertiesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(itemLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(propertiesLabel)
        
        NSLayoutConstraint.activate([itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
                                     itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                                     itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                                     itemLabel.heightAnchor.constraint(equalToConstant: 16)])
        
        NSLayoutConstraint.activate([timestampLabel.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 4),
                                     timestampLabel.leadingAnchor.constraint(equalTo: itemLabel.leadingAnchor),
                                     timestampLabel.trailingAnchor.constraint(equalTo: itemLabel.trailingAnchor),
                                     timestampLabel.heightAnchor.constraint(equalToConstant: 12)])
        
        NSLayoutConstraint.activate([propertiesLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 4),
                                     propertiesLabel.leadingAnchor.constraint(equalTo: timestampLabel.leadingAnchor),
                                     propertiesLabel.trailingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
                                     propertiesLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 14),
                                     propertiesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }
    
}

// MARK: - Private Extension

/// Specifically, this is an extension of LoggedItemProperties which is typed as [String: AnyTraceEquatable]
private extension Dictionary where Key: ExpressibleByStringLiteral, Value: CustomStringConvertible {
    
    var loggerDescription: String {
        var v = ""
        for (key, value) in self {
            v += ("\(key)" + ": \(value)\n")
        }
        return v
    }
    
}