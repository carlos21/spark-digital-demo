//
//  PhotoResponse.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

public struct PhotoResponse: Decodable {
    
    public let id: Int
    public let title: String
    public let url: String
    public let thumbnailUrl: String
}
