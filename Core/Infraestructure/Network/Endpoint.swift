//
//  Endpoint.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/16/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public class Endpoint<Response>: ResponseRequestable {
    public var path: String
    public var isFullPath: Bool
    public var method: HTTPMethod
    public var headerParamaters: [String: String]
    public var queryParametersEncodable: Encodable? = nil
    public var queryParameters: [String: Any]
    public var bodyParamatersEncodable: Encodable? = nil
    public var bodyParamaters: [String: Any]
    public var bodyEncoding: BodyEncoding
    public var responseDecoder: ResponseDecoder
    
    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethod,
         headerParameters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoding: BodyEncoding = .jsonSerializationData,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParamaters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParamatersEncodable = bodyParametersEncodable
        self.bodyParamaters = bodyParameters
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}
