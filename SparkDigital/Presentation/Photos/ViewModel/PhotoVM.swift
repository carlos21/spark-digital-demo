//
//  PhotoVM.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

/// Holds the properties of a photo and the states
class PhotoVM {
    
    /// Title
    let title: String
    
    /// URL of the big image
    let url: String
    
    /// Thumbnail url
    let thumbnailUrl: String
    
    /// Thumbnail state
    var thumbnailState: PhotoState
    
    /// Big image state
    var bigImageState: PhotoState
    
    /// Quick accessor to get the thumbnail image data
    var thumbnailData: Data? {
        switch thumbnailState {
        case .success(let data):
            return data
            
        default:
            return nil
        }
    }
    
    /// Quick accessor to get the big image data
    var bigImageData: Data? {
        switch bigImageState {
        case .success(let data):
            return data
            
        default:
            return thumbnailData
        }
    }
    
    /// Initializer
    init(title: String, url: String, thumbnailUrl: String, thumbnailState: PhotoState, bigImageState: PhotoState) {
        self.title = title
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailState = thumbnailState
        self.bigImageState = bigImageState
    }
}
