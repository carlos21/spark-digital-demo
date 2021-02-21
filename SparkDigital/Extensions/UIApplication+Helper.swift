//
//  UIApplication+Version.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import UIKit

extension UIApplication {
    
    var infoDictionary: [String: Any]? { return Bundle.main.infoDictionary }
    
    var currentVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var isUnitTesting: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        #else
        return false
        #endif
    }
}
