//
//  MockNetworkSessionManager.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

struct MockNetworkSessionManager: NetworkSessionManagerProtocol {
    
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        completion(data, response, error)
        return URLSessionDataTask()
    }
}
