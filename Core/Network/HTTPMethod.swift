//
//  HTTPMethod.swift
//  CoinRankingSwiftUI
//
//  Created by Carlos Duclos on 8/7/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    
    case connect = "CONNECT"
    case delete  = "DELETE"
    case get     = "GET"
    case head    = "HEAD"
    case options = "OPTIONS"
    case patch   = "PATCH"
    case post    = "POST"
    case put     = "PUT"
    case trace   = "TRACE"
}
