//
//  JSON.swift
//  Core
//
//  Created by Carlos Duclos on 11/20/20.
//

import Foundation

public struct JSONCoding {
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom
        return decoder
    }
    
    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom
        return encoder
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    
    static let custom: JSONDecoder.DateDecodingStrategy = .custom(decode)
    
    private static func decode(_ decoder: Decoder) throws -> Date {
        let singleValueContainer = try decoder.singleValueContainer()
        let dateString = try singleValueContainer.decode(String.self)
        guard let date = Date(custom: dateString) else {
            throw DecodingError.typeMismatch(Date.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Invalid date string.")) }
        return date
    }
}

public extension JSONEncoder.DateEncodingStrategy {
    
    static let custom: JSONEncoder.DateEncodingStrategy = .custom(encode(date:_:))
    
    private static func encode(date: Date, _ encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        let string = DateFormatter.defaultFormat.string(from: date)
        try singleValueContainer.encode(string)
    }
}
