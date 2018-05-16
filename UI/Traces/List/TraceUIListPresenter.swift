//
//  TraceUIListPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUIListPresenter: Presenting {
    
    init(view: TraceUIListView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Presenting
    
    func listenForChanges() {
        TraceUISignals.Traces.added.listen { newTraces in
            self.traces.append(contentsOf: newTraces)
            self.view.configure(with: TraceUIListViewModel(traces: self.traces))
        }
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIListView
    private var traces = [Traceable]()
    
}
