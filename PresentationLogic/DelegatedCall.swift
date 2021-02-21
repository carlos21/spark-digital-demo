//
//  DelegatedCall.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

public typealias Callback = (() -> Void)

public struct DelegatedCall<Input> {
    
    public private(set) var callback: ((Input) -> Void)?
    
    public mutating func delegate<Delegate : AnyObject>(to delegate: Delegate, with callback: @escaping (Delegate, Input) -> Void) {
        self.callback = { [weak delegate] input in
            guard let delegate = delegate else { return }
            callback(delegate, input)
        }
    }
    
    public init() { }
}

public struct DelegatedReturnCall<Input, Output> {
    
    private(set) var callback: ((Input) -> Output?)?
    
    public mutating func delegate<Delegate : AnyObject>(to delegate: Delegate, with callback: @escaping (Delegate, Input) -> Output?) {
        self.callback = { [weak delegate] input in
            guard let delegate = delegate else { return nil }
            return callback(delegate, input)
        }
    }
    
    public init() { }
}
