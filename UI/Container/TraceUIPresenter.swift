//
//  TraceUIPresenter.swift
//  Tracer
//
//  Created by Rob Phillips on 5/14/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUIPresenter: Presenting {
    
    init(view: TraceUIView) {
        self.view = view
        
        listenForChanges()
    }
    
    // MARK: - Private Properties
    
    private let view: TraceUIView
    
}

private extension TraceUIPresenter {
    
    func listenForChanges() {
        TraceUISignals.UI.showLogger.listen { _ in
            self.view.configure(with: TraceUIViewModel(viewName: .loggerList))
        }
        
        TraceUISignals.UI.showTraces.listen { _ in
            self.view.configure(with: TraceUIViewModel(viewName: .traceList))
        }
        
        TraceUISignals.UI.showTraceDetail.listen { _ in
            self.view.configure(with: TraceUIViewModel(viewName: .traceDetail))
        }
        
        TraceUISignals.UI.closeTraceDetail.listen { _ in
            self.view.configure(with: TraceUIViewModel(viewName: .traceList))
        }
    }
    
}
