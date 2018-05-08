//
//  AppDelegate.swift
//  TraceUIExample
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit
import Tracer

private(set) var App: AppDelegate!

@UIApplicationMain
class AppDelegate: UIResponder {
    
    // MARK: - Instantiation
    
    override init() {
        self.traceUICoordinator = TraceUICoordinator()
        
        super.init()
        
        App = self
    }
    
    // MARK: - Properties
    
    var window: UIWindow?
    let traceUICoordinator: TraceUICoordinator

}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        traceUICoordinator.start()
        return true
    }
    
}

