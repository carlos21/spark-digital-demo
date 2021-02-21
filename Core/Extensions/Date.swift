//
//  Date.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

public extension Date {
    
    init?(custom string: String) {
        if let date = DateFormatter.defaultFormat.date(from: string) {
            self = date
            return
        }
        
        return nil
    }
}
