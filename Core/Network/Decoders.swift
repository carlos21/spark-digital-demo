//
//  Decoders.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/16/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public protocol ResponseDecoder {
    
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public class JSONResponseDecoder: ResponseDecoder {
    
    private let jsonDecoder = JSONCoding.decoder
    
    public init() { }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
