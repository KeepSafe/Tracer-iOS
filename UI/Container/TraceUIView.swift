//
//  TraceUIView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUIView: UIView, Viewing {
    
    // MARK: - Instantiation
    
    init(viewModel: TraceUIViewModel = TraceUIViewModel(viewName: .loggerList)) {
        self.viewModel = viewModel
        
        self.tabView = TraceUITabView()
        self.tabViewPresenter = TraceUITabPresenter(view: self.tabView)
        
        self.loggerListView = ItemLoggerListView()
        self.loggerListPresenter = ItemLoggerListPresenter(view: self.loggerListView)
        
        self.traceListView = TraceUIListView()
        self.traceListPresenter = TraceUIListPresenter(view: self.traceListView)
        
        self.traceDetailView = TraceUIDetailView()
        self.traceDetailPresenter = TraceUIDetailPresenter(view: self.traceDetailView)
        
        self.settingsView = TraceUISettingsView()
        self.settingsViewPresenter = TraceUISettingsPresenter(view: self.settingsView)
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - API
    
    func configure(with viewModel: TraceUIViewModel) {
        switch viewModel.viewName {
        case .loggerList:
            display(viewToDisplay: loggerListView, andHide: [traceListView, traceDetailView])
        case .traceList:
            display(viewToDisplay: traceListView, andHide: [loggerListView, traceDetailView])
        case .traceDetail:
            display(viewToDisplay: traceDetailView, andHide: [loggerListView, traceListView])
        }
    }
    
    // MARK: - Properties
    
    var settingsActionSheet: UIAlertController {
        return settingsView.alertController
    }
    
    // MARK: - Private Properties
    
    private var viewModel: TraceUIViewModel
    
    private let tabView: TraceUITabView
    private let tabViewPresenter: TraceUITabPresenter
    
    private let loggerListView: ItemLoggerListView
    private let loggerListPresenter: ItemLoggerListPresenter
    
    private let traceListView: TraceUIListView
    private let traceListPresenter: TraceUIListPresenter
    
    private let traceDetailView: TraceUIDetailView
    private let traceDetailPresenter: TraceUIDetailPresenter
    
    private let settingsView: TraceUISettingsView
    private let settingsViewPresenter: TraceUISettingsPresenter
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUIView {
    
    func setupView() {
        backgroundColor = .white
        
        setupTabView()
        setup(view: loggerListView)
        setup(view: traceListView)
        setup(view: traceDetailView)
        
        configure(with: viewModel)
    }
    
    func setupTabView() {
        let superview = self
        tabView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(tabView)
        
        NSLayoutConstraint.activate([tabView.topAnchor.constraint(equalTo: superview.topAnchor),
                                     tabView.heightAnchor.constraint(equalToConstant: TraceUITabView.height),
                                     tabView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     tabView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
    func setup(view: UIView) {
        let superview = self
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
        
        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: tabView.bottomAnchor),
                                     view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
    }
    
    func display(viewToDisplay: UIView, andHide viewsToHide: [UIView]) {
        UIView.animate(withDuration: TraceAnimation.duration, animations: {
            for viewToHide in viewsToHide {
                viewToHide.alpha = 0
            }
            viewToDisplay.alpha = 1
        })
    }
    
}

