//
//  TraceUIListView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIListView: UIView, Viewing {
    
    // MARK: - Instantiation
    
    init(viewModel: TraceUIListViewModel = TraceUIListViewModel(traces: [])) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - View Model
    
    func configure(with newViewModel: TraceUIListViewModel) {
        viewModel = newViewModel
        tableView.reloadData()
    }
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = { [unowned self] in
        let table = UITableView(frame: .zero)
        table.register(TraceUIListItemCell.self, forCellReuseIdentifier: TraceUIListItemCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = TraceUIListItemCell.height
        table.tableFooterView = UIView(frame: .zero)
        return table
    }()
    
    private var viewModel: TraceUIListViewModel
    
    // MARK: - Unsupported Initializers
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - UITableViewDataSource

extension TraceUIListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.traces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TraceUIListItemCell.identifier, for: indexPath) as? TraceUIListItemCell else { fatalError("Could not dequeue cell") }
        let trace = viewModel.traces[indexPath.row]
        cell.configure(with: trace)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TraceUIListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        TraceUISignals.UI.showTraceDetail.fire(data: viewModel.traces[indexPath.row])
    }
    
}

// MARK: - Private API

private extension TraceUIListView {
    
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

