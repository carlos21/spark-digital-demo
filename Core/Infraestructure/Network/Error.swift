//
//  Error.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/16/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

enum RequestGenerationError: Error {
    
    case components
}

public extension Error {
    
    /// Code of the error
    var code: ErrorCode {
        let nativeCode = (self as NSError).code
        return ErrorCode(rawValue: nativeCode)
    }
    
    /// Domain of the error
    var domain: String { return (self as NSError).domain }
}

/// Custom type to represent Error codes
public struct ErrorCode: RawRepresentable, Equatable {
    
    public static let cancelled = ErrorCode(-999)
    
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    private init(_ unsafe: Int) {
        self.rawValue = unsafe
    }
    
    public static func == (lhs: ErrorCode?, rhs: ErrorCode) -> Bool {
        guard let code = lhs?.rawValue else { return false }
        return code == rhs.rawValue
    }
}
