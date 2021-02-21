//
//  NetworkService.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/9/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public enum NetworkError: Error, Equatable {
    
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.error(let statusCode1, let data1), .error(let statusCode2, let data2)):
            return statusCode1 == statusCode2 && data1 == data2
            
        case (.notConnected, .notConnected):
            return true
            
        case (.cancelled, .cancelled):
            return true
            
        case (.urlGeneration, .urlGeneration):
            return true
            
        case (.generic(let error1), .generic(let error2)):
            return error1.code == error2.code
            
        default:
            return false
        }
    }
}

public protocol NetworkCancellable {
    
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }

public typealias ProgressHandler = (Int) -> Void

public protocol NetworkSessionManagerProtocol {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}

public class NetworkSessionManager: NSObject, NetworkSessionManagerProtocol {
    
    var progressHandler: ProgressHandler?
    
    private var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 60
        config.timeoutIntervalForRequest = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCredentialStorage = nil
        config.urlCache = nil
        return config
    }
    
    public override init () {
        super.init()
    }
    
    public func request(request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

extension NetworkSessionManager: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        let uploadProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend) * 100
        self.progressHandler?(Int(uploadProgress))
    }
}

public protocol NetworkServiceProtocol {
    
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable,
                 completion: @escaping CompletionHandler,
                 progressHandler: ProgressHandler?) -> NetworkCancellable?
}

public final class NetworkService {
    
    private let config: NetworkConfigProtocol
    private let sessionManager: NetworkSessionManagerProtocol
    private let logger: NetworkErrorLoggerProtocol
    
    public init(config: NetworkConfigProtocol,
                sessionManager: NetworkSessionManagerProtocol = NetworkSessionManager(),
                logger: NetworkErrorLoggerProtocol = NetworkErrorLogger()) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }
    
    private func request(request: URLRequest,
                         completion: @escaping CompletionHandler) -> NetworkCancellable {
        let dataTask = sessionManager.request(request: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let requestError = error {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                let response = response as? HTTPURLResponse
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        return dataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet:
            return .notConnected
            
        case .cancelled:
            return .cancelled
            
        default:
            return .generic(error)
        }
    }
}

extension NetworkService: NetworkServiceProtocol {
    
    public func request(endpoint: Requestable,
                        completion: @escaping CompletionHandler,
                        progressHandler: ProgressHandler? = nil) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}
