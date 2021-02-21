//
//  API.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

struct API { }

extension API {
    
    struct Photo {
        
        static func getList() -> Endpoint<[PhotoResponse]> {
            return Endpoint(path: "photos", method: .get)
        }
    }
}

extension API {
    
    struct Image {
        
        static func getImage(path: String) -> Endpoint<Data> {
            return Endpoint(path: path,
                            isFullPath: true,
                            method: .get,
                            responseDecoder: RawDataResponseDecoder())
        }
    }
}
