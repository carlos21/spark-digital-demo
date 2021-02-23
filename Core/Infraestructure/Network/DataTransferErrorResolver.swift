//
//  DataTransferErrorResolver.swift
//  Core
//
//  Created by Carlos Duclos on 10/11/20.
//

import Foundation

public protocol DataTransferErrorResolverProtocol {
    
    func resolve(error: NetworkError) -> Error
}

public class DataTransferErrorResolver: DataTransferErrorResolverProtocol {
    
    public init() {}
    
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}
