//
//  AppContainer.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import UIKit
import Core

/// Default implementation for the app
final class AppContainer {
    
    /// Singleton implementation
    static let shared = AppContainer()
    
    /// Defines the default transfer service to use in the app
    /// Holds the default base url, headers and app version
    var dataTransferService: DataTransferService {
        let config = NetworkConfig(baseURL: Environment.dev.baseUrl,
                                   headers: [
                                    "platform": "ios",
                                    "version": UIApplication.shared.currentVersion ?? ""
                                   ])
        let apiDataNetwork = NetworkService(config: config)
        return DataTransferService(with: apiDataNetwork)
    }
}
