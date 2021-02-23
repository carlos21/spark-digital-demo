//
//  PhotoVM.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

/// Holds the properties of a photo and the states
public class PhotoVM {
    
    /// Title
    public let title: String
    
    /// URL of the big image
    public let url: String
    
    /// Thumbnail url
    public let thumbnailUrl: String
    
    /// Thumbnail state
    public var thumbnailState: PhotoState
    
    /// Big image state
    public var bigImageState: PhotoState
    
    /// Quick accessor to get the thumbnail image data
    public var thumbnailData: Data? {
        switch thumbnailState {
        case .success(let data):
            return data
            
        default:
            return nil
        }
    }
    
    /// Quick accessor to get the big image data
    public var bigImageData: Data? {
        switch bigImageState {
        case .success(let data):
            return data
            
        default:
            return thumbnailData
        }
    }
    
    init(title: String, url: String, thumbnailUrl: String, thumbnailState: PhotoState, bigImageState: PhotoState) {
        self.title = title
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailState = thumbnailState
        self.bigImageState = bigImageState
    }
}
