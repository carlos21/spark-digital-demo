//
//  PhotoVM.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

public class PhotoVM {
    
    public let title: String
    public let url: String
    public let thumbnailUrl: String
    public var thumbnailState: PhotoState
    public var bigImageState: PhotoState
    
    public var thumbnailData: Data? {
        switch thumbnailState {
        case .success(let data):
            return data
            
        default:
            return nil
        }
    }
    
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
