//
//  DataTransferService.swift
//  LUX
//
//  Created by Carlos Duclos on 9/27/20.
//

import Foundation

public enum DataTransferError: Error, Equatable {
    
    /// There is no response from the server
    case noResponse
    
    /// Error when parsing the server's response
    case parsing(Error)
    
    /// Connection error
    case networkFailure(NetworkError)
    
    case resolvedNetworkFailure(Error)
    
    /// Token expired
    case tokenExpired
    
    /// Equatable implementation to allow comparison in one line of code
    public static func == (lhs: DataTransferError, rhs: DataTransferError) -> Bool {
        switch (lhs, rhs) {
        case (.noResponse, .noResponse):
            return true
            
        case (.tokenExpired, .tokenExpired):
            return true
            
        case (.parsing, .parsing):
            return true
            
        case (.networkFailure(let error1), .networkFailure(let error2)):
            return error1 == error2
            
        case (.resolvedNetworkFailure(let error1), .resolvedNetworkFailure(let error2)):
            return error1.code == error2.code
            
        default:
            return false
        }
    }
}

public protocol DataTransferServiceProtocol {
    
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    @discardableResult
    func request<T: Decodable,
                 E: ResponseRequestable>(with endpoint: E,
                                         completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable,
                 E: ResponseRequestable>(with endpoint: E,
                                         progressHandler: ProgressHandler?,
                                         completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
}

public final class DataTransferService {
    
    private let networkService: NetworkServiceProtocol
    private let errorResolver: DataTransferErrorResolverProtocol
    private let errorLogger: DataTransferErrorLoggerProtocol
    
    public init(with networkService: NetworkServiceProtocol,
                errorResolver: DataTransferErrorResolverProtocol = DataTransferErrorResolver(),
                errorLogger: DataTransferErrorLoggerProtocol = DataTransferErrorLogger()) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DataTransferService: DataTransferServiceProtocol {
    
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {
        return request(with: endpoint, progressHandler: nil, completion: completion)
    }
    
    public func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        progressHandler: ProgressHandler?,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {
        return self.networkService.request(endpoint: endpoint, completion: { result in
            switch result {
            case .success(let response):
                let result: Result<T, DataTransferError> = self.decode(data: response,
                                                                       decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { completion(result) }
                
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }, progressHandler: progressHandler)
    }
    
    private func decode<T: Decodable>(data: Data?,
                                      decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}
