//
//  MockNetworkConfigurable.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

class NetworkConfigurableMock: NetworkConfigProtocol {
    
    var baseURL: URL = URL(string: "https://mock.test.com")!
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
