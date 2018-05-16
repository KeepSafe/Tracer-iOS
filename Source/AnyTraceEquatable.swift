//
//  AnyTraceEquatable.swift
//  Tracer
//
//  Created by Rob Phillips on 4/27/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

/// Type erased box for any value conforming to `Equatable`
/// which allows for polymorphic non-homogeneity amongst items in collections.
///
/// E.g. let itemsToMatch: = [AnyTraceEquatable("string"),
///                           AnyTraceEquatable(["a", "b", "c"]),
///                           AnyTraceEquatable(["key": "value"]),
///                           AnyTraceEquatable(myCustomEquatableType)]
///
/// Note: this boxed type erasure design pattern comes from `AnyHashable`
/// via https://github.com/apple/swift/blob/master/stdlib/public/core/AnyHashable.swift
/// and avoids a lot of issues with using generic constraints at a protocol level.
public struct AnyTraceEquatable: Equatable, CustomStringConvertible {
    public init<H: Equatable>(_ base: H) {
        _box = _ConcreteTraceEquatableBox(base)
    }
    
    /// Determines whether values in the boxes are equivalent at a type and value level.
    ///
    /// Returns `false` if the boxed values store different types where
    /// no comparison is possible (e.g. edge cases like comparing Int(1) and
    /// UInt(1) or more obvious cases like comparing a String to an Array).
    /// Otherwise, contains the result of `==` between two values of the same type.
    public static func == (lhs: AnyTraceEquatable, rhs: AnyTraceEquatable) -> Bool {
        return lhs._box._isEqual(to: rhs._box) ?? false
    }
    
    /// A description of the base value
    public var description: String {
        return _box.description
    }
    
    private let _box: _AnyTraceEquatableBox
    private init() { fatalError("init not supported") }
}

/// We use this to give us full equality checks at a type level
fileprivate protocol _AnyTraceEquatableBox: CustomStringConvertible {
    func _isEqual(to: _AnyTraceEquatableBox) -> Bool?
    func _unbox<T: Equatable>() -> T?
}

/// We use this as a generic concrete box with full equality checks at a type level
fileprivate struct _ConcreteTraceEquatableBox<Base: Equatable>: _AnyTraceEquatableBox {
    init(_ base: Base) {
        _baseEquatable = base
    }
    
    /// Unboxes the value back into its base `Equatable` type
    func _unbox<T: Equatable>() -> T? {
        return (self as _AnyTraceEquatableBox as? _ConcreteTraceEquatableBox<T>)?._baseEquatable
    }
    
    /// Determines whether values in the boxes are equivalent at a type and value level.
    ///
    /// Returns `nil` if the boxed values store different types where
    /// no comparison is possible (e.g. edge cases like comparing Int(1) and
    /// UInt(1) or more obvious cases like comparing a String to an Array).
    /// Otherwise, contains the result of `==` between two values of the same type.
    func _isEqual(to rhs: _AnyTraceEquatableBox) -> Bool? {
        if let rhs: Base = rhs._unbox() {
            return _baseEquatable == rhs
        }
        return nil
    }
    
    /// A description of the base value
    var description: String {
        return String(describing: _baseEquatable)
    }
    
    /// Stores the base `Equatable` value without erasing its type
    let _baseEquatable: Base
}
