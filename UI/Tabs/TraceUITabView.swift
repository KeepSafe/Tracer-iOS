//
//  TraceUITabView.swift
//  Tracer
//
//  Created by Rob Phillips on 5/10/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

final class TraceUITabView: UIView, Viewing {
    
    static let height: CGFloat = 44
    
    // MARK: - Instantiation
    
    init(viewModel: TraceUITabViewModel = TraceUITabViewModel.defaultConfiguration) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupView()
        configure(with: viewModel)
    }
    
    // MARK: - View Model
    
    func configure(with newViewModel: TraceUITabViewModel) {
        viewModel = newViewModel
        
        UIView.animate(withDuration: TraceAnimation.duration) {
            self.logsTracesSegmentButton.alpha = self.viewModel.showLogsTracesSegmentButton ? 1 : 0
            self.closeTraceDetailButton.alpha = self.viewModel.showCloseTraceDetailButton ? 1 : 0
            self.startStopTraceButton.alpha = self.viewModel.showStartStopTraceButton ? 1 : 0
            self.settingsButton.alpha = self.viewModel.showSettingsButton ? 1 : 0
            self.exportTraceButton.alpha = self.viewModel.showExportTraceButton ? 1 : 0
            self.collapseUIToolButton.alpha = self.viewModel.showCollapseUIToolButton ? 1 : 0
        }
        
        logsTracesSegmentButton.configure(loggerTabActive: viewModel.showLogger)
        startStopTraceButton.configure(traceName: viewModel.traceName ?? "", state: viewModel.startStopButtonState)
    }
    
    // MARK: - Private Properties
    
    private var viewModel: TraceUITabViewModel

    private lazy var logsTracesSegmentButton: TraceUITabSegmentButton = {
        let view = TraceUITabSegmentButton()
        view.alpha = 0
        return view
    }()
    
    private lazy var closeTraceDetailButton: TraceUIIconButton = {
        let button = TraceUIIconButton(icon: .inBundle(named: "CloseIcon"), backgroundColor: .clear, tapped: {
            TraceUISignals.UI.closeTraceDetail.fire(data: nil)
        })
        button.accessibilityLabel = "CloseTraceDetails"
        button.alpha = 0
        return button
    }()
    
    private lazy var startStopTraceButton: TraceUIStartStopButton = {
        let view = TraceUIStartStopButton()
        view.alpha = 0
        return view
    }()
    
    private lazy var settingsButton: TraceUIIconButton = { [unowned self] in
        let button = TraceUIIconButton(icon: .inBundle(named: "SettingsIcon"), backgroundColor: .clear, tapped: {
            TraceUISignals.UI.showSettings.fire(data: self.settingsButton)
        })
        button.accessibilityLabel = "ShowTraceSettings"
        button.alpha = 0
        return button
    }()
    
    private lazy var exportTraceButton: TraceUIIconButton = {
        let button = TraceUIIconButton(icon: .inBundle(named: "ExportIcon"), backgroundColor: .clear, tapped: {
            TraceUISignals.UI.exportTrace.fire(data: nil)
        })
        button.accessibilityLabel = "ExportTraceReport"
        button.alpha = 0
        return button
    }()
    
    private lazy var collapseUIToolButton: TraceUIIconButton = {
        let button = TraceUIIconButton(icon: .inBundle(named: "DownArrow"), backgroundColor: UIColor.TraceUI.blueGray, tapped: {
            TraceUISignals.UI.collapseTool.fire(data: nil)
        })
        button.accessibilityLabel = "CollapseTraceUI"
        button.alpha = 0
        return button
    }()
    
    // MARK: - Unsupported Initializers
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

private extension TraceUITabView {
    
    func setupView() {
        backgroundColor = UIColor.TraceUI.lightGray
        
        logsTracesSegmentButton.translatesAutoresizingMaskIntoConstraints = false
        closeTraceDetailButton.translatesAutoresizingMaskIntoConstraints = false
        startStopTraceButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        exportTraceButton.translatesAutoresizingMaskIntoConstraints = false
        collapseUIToolButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logsTracesSegmentButton)
        addSubview(closeTraceDetailButton)
        addSubview(startStopTraceButton)
        addSubview(settingsButton)
        addSubview(exportTraceButton)
        addSubview(collapseUIToolButton)

        let superview = self
        
        NSLayoutConstraint.activate([superview.heightAnchor.constraint(equalToConstant: TraceUITabView.height)])
        
        NSLayoutConstraint.activate([logsTracesSegmentButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     logsTracesSegmentButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     logsTracesSegmentButton.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     logsTracesSegmentButton.widthAnchor.constraint(equalToConstant: TraceUITabSegmentButton.width)])
        
        NSLayoutConstraint.activate([startStopTraceButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     startStopTraceButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     startStopTraceButton.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: -startStopTraceButton.centeringDistance),
                                     startStopTraceButton.widthAnchor.constraint(lessThanOrEqualTo: superview.widthAnchor, multiplier: 0.65)])
        
        NSLayoutConstraint.activate([closeTraceDetailButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     closeTraceDetailButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     closeTraceDetailButton.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                     closeTraceDetailButton.widthAnchor.constraint(equalToConstant: TraceUIIconButton.edgeLength)])
        
        NSLayoutConstraint.activate([collapseUIToolButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     collapseUIToolButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     collapseUIToolButton.rightAnchor.constraint(equalTo: superview.rightAnchor),
                                     collapseUIToolButton.widthAnchor.constraint(equalToConstant: TraceUIIconButton.edgeLength)])
        
        NSLayoutConstraint.activate([settingsButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     settingsButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     settingsButton.rightAnchor.constraint(equalTo: collapseUIToolButton.leftAnchor),
                                     settingsButton.widthAnchor.constraint(equalToConstant: TraceUIIconButton.edgeLength)])
        
        NSLayoutConstraint.activate([exportTraceButton.topAnchor.constraint(equalTo: superview.topAnchor),
                                     exportTraceButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                     exportTraceButton.rightAnchor.constraint(equalTo: collapseUIToolButton.leftAnchor),
                                     exportTraceButton.widthAnchor.constraint(equalToConstant: TraceUIIconButton.edgeLength)])
    }
    
}
