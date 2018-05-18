//
//  TraceUIToast.swift
//  Tracer
//
//  Created by Rob Phillips on 5/18/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

final class TraceUIToast: Operation {
    
    init(viewModel: TraceUIToastViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - API
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
    
    // MARK: - Properties
    
    lazy var view: TraceUIToastView = { [unowned self] in
        return TraceUIToastView(viewModel: self.viewModel)
    }()
    
    // MARK: - Overrides
    
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: #function)
            _finished = newValue
            didChangeValue(forKey: #function)
        }
    }
    
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: #function)
            _executing = newValue
            didChangeValue(forKey: #function)
        }
    }
    
    override func start() {
        guard (isFinished == false && isCancelled == false && isExecuting == false) else { return }
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.start() }
            return
        }
        main()
    }
    
    override func main() {
        isExecuting = true
        TraceUISignals.Toasts.show.fire(data: self)
    }
    
    override func cancel() {
        finish()
        super.cancel()
        view.removeFromSuperview()
    }
    
    // MARK: - Private Properties
    
    private let viewModel: TraceUIToastViewModel
    
    private var _finished = false
    private var _executing = false
    
}
