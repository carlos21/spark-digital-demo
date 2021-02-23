//
//  Requestable.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/13/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public enum BodyEncoding {
    
    case jsonSerializationData
    case stringEncodingAscii
}

/// Defines the template for the object that will hold the necessary data to sent to the server
public protocol Requestable {
    
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethod { get }
    var headerParamaters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParamatersEncodable: Encodable? { get }
    var bodyParamaters: [String: Any] { get }
    var bodyEncoding: BodyEncoding { get }
    
    func urlRequest(with networkConfig: NetworkConfigProtocol) throws -> URLRequest
}

extension Requestable {
    
    /// Returns a generated URL
    /// - Parameters:
    ///     - config: Holds the baseUrl, headers and query parameters
    func url(with config: NetworkConfigProtocol) throws -> URL {
        if isFullPath {
            guard let url = URL(string: path) else { throw RequestGenerationError.components }
            return url
        }
        
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()

        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }
    
    /// Returns a generated URLRequest
    /// - Parameters:
    ///     - config: Holds the baseUrl, headers and query parameters
    public func urlRequest(with config: NetworkConfigProtocol) throws -> URLRequest {
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParamaters.forEach { allHeaders.updateValue($1, forKey: $0) }
        
        allHeaders["Content-Type"] = "application/json"
        allHeaders["Accept"] = "application/json"

        let bodyParamaters = try bodyParamatersEncodable?.toDictionary() ?? self.bodyParamaters
        if !bodyParamaters.isEmpty {
            urlRequest.httpBody = try encodeBody(bodyParamaters: bodyParamaters,
                                                 encoding: bodyEncoding)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }
    
    /// Returns a generated URLRequest
    /// - Parameters:
    ///     - bodyParamaters: Dictionary that holds data on the HTTP body
    ///     - encoding: Encoding type
    private func encodeBody(bodyParamaters: [String: Any],
                            encoding: BodyEncoding) throws -> Data? {
        switch encoding {
        case .jsonSerializationData:
            return try JSONSerialization.data(withJSONObject: bodyParamaters)
            
        case .stringEncodingAscii:
            return bodyParamaters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        }
    }
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

private extension Encodable {
    
    /// Returns a dictionary based on an encodable object
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONCoding.encoder.encode(self)
        let josnData = try JSONSerialization.jsonObject(with: data)
        return josnData as? [String : Any]
    }
}

private extension Dictionary {
    
    /// Returns an string based on a dictionary. It's used to send query parameters
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}
