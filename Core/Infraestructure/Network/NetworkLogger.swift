//
//  NetworkLogger.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/13/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public protocol NetworkErrorLoggerProtocol {
    
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

public final class NetworkErrorLogger: NetworkErrorLoggerProtocol {
    
    public init() {}
    
    public func log(request: URLRequest) {
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            printIfDebug("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(String(describing: resultString))")
        }
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let string = String(data: data, encoding: .utf8) {
            printIfDebug("responseData: \(string)")
        }
    }

    public func log(error: Error) {
        printIfDebug("\(error)")
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
