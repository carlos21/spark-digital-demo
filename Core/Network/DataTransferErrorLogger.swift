//
//  DataTransferErrorLogger.swift
//  Core
//
//  Created by Carlos Duclos on 10/11/20.
//

import Foundation

public protocol DataTransferErrorLoggerProtocol {
    
    func log(error: Error)
}

public final class DataTransferErrorLogger: DataTransferErrorLoggerProtocol {
    
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}
