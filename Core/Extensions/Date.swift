//
//  Date.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

public extension Date {
    
    /// Instantiates a date using a default format yyyy-MM-dd HH:mm:ss zzz
    init?(custom string: String) {
        if let date = DateFormatter.defaultFormat.date(from: string) {
            self = date
            return
        }
        return nil
    }
}
