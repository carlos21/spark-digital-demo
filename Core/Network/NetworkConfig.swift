//
//  NetworkConfigurable.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/9/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public protocol NetworkConfigProtocol {
    
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

public struct NetworkConfig: NetworkConfigProtocol {
    
    public let baseURL: URL
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
    public init(baseURL: URL,
                headers: [String: String] = [:],
                queryParameters: [String: String] = [:]) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
