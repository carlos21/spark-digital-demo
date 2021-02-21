//
//  Stat.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

public enum ListState {
    
    case idle
    case loading
    case success
    case error(String)
}

public enum PhotoState {
    
    case idle
    case loading
    case success(Data)
    case error
    
    var shouldDownload: Bool {
        switch self {
        case .idle, .error:
            return true
            
        default:
            return false
        }
    }
    
    public var data: Data? {
        switch self {
        case .success(let data):
            return data
            
        default:
            return nil
        }
    }
}
