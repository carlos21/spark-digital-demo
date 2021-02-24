//
//  Stat.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

public enum ListState {
    
    /// No actions yet
    case idle
    
    /// The list is being retrieved from the server
    case loading
    
    /// The list was successfully gotten from the server
    case success
    
    /// The was an error getting the list
    case error
}

public enum PhotoState {
    
    /// No actions yet
    case idle
    
    /// The photo is being retrieved from the server
    case loading
    
    /// The photo was successfully gotten from the server
    case success(Data)
    
    /// The was an error getting the list
    case error
    
    /// Indicated if the download should start or not
    var shouldDownload: Bool {
        switch self {
        case .idle, .error:
            return true
            
        default:
            return false
        }
    }
    
    /// Quick access to get the image data
    public var data: Data? {
        switch self {
        case .success(let data):
            return data
            
        default:
            return nil
        }
    }
}

extension PhotoState: Equatable {
    
    public static func ==(lhs: PhotoState, rhs: PhotoState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
            
        case (.loading, .loading):
            return true
            
        case (.success, .success):
            return true
        
        case (.error, .error):
            return true
        
        default:
            return false
        }
    }
}

extension ListState: Equatable {
    
    public static func ==(lhs: ListState, rhs: ListState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
            
        case (.loading, .loading):
            return true
            
        case (.success, .success):
            return true
        
        case (.error, .error):
            return true
        
        default:
            return false
        }
    }
}
