//
//  TraceUIProtocols.swift
//  Tracer
//
//  Created by Rob Phillips on 5/8/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

///
/// Protocols used to mark how various concerns are isolated
/// i.e. these aren't always used to enforce type or file naming
///      and could be used to segment a given file into concerns
///

/// Presenters for coordinating view model changes and displaying them in views
internal protocol Presenting: Listening {}

/// View models used to display data in a view
internal protocol ViewModeling {}

/// Views, agnostic of business logic and populated with a view model
internal protocol Viewing {}

/// Services that listen for actions and apply them to the services they control
internal protocol Servicing {}

/// Listens for generic changes
internal protocol Listening {}
