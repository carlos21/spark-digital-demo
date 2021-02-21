//
//  DateFormatter.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

extension DateFormatter {
    
    public static let defaultFormat: DateFormatter = {
        let formatter =  DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        return formatter
    }()
}
