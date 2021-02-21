//
//  Environment.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

public enum Environment: String {
    
    case dev
    
    public var baseUrl: URL {
        switch self {
        case .dev: return URL(string: "https://jsonplaceholder.typicode.com/")!
        }
    }
}
