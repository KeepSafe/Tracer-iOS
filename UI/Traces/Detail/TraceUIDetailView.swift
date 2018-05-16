//
//  TraceUIDetailView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIDetailView: UIView, Viewing {
    
    // MARK: - Instantiation
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - View Model
    
    func configure(with newViewModel: TraceUIDetailViewModel) {
        viewModel = newViewModel
        
        tableView.tableHeaderView = nil
        if let setupSteps = viewModel?.trace.setupStepsAsList {
            tableView.tableHeaderView = TraceUIDetailHeaderView(setupSteps: setupSteps)
            tableView.tracer_enableVariableHeightTableHeaderView()
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = { [unowned self] in
        let table = UITableView(frame: .zero)
        table.register(TraceUIDetailItemCell.self, forCellReuseIdentifier: TraceUIDetailItemCell.identifier)
        table.dataSource = self
        table.estimatedRowHeight = TraceUIListItemCell.height
        table.tableFooterView = UIView(frame: .zero)
        return table
    }()
    
    private var viewModel: TraceUIDetailViewModel?
    
    // MARK: - Unsupported Initializers
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - UITableViewDataSource

extension TraceUIDetailView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.trace.itemsToMatch.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TraceUIDetailItemCell.identifier, for: indexPath) as? TraceUIDetailItemCell else { fatalError("Could not dequeue cell") }
        guard let traceItem = viewModel?.trace.itemsToMatch[indexPath.row],
              let isTraceRunning = viewModel?.isTraceRunning,
              let state = viewModel?.statesForItemsToMatch[indexPath.row].values.first
            else { return cell }
        cell.configure(with: traceItem, isTraceRunning: isTraceRunning, state: state)
        return cell
    }
    
}

// MARK: - Private API

private extension TraceUIDetailView {
    
    func setupView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        let superview = self
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
}
