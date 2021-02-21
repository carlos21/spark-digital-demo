//
//  AppContainer.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import UIKit
import Core

final class AppContainer {
    
    static let shared = AppContainer()
    
    var dataTransferService: DataTransferService {
        let config = NetworkConfig(baseURL: Environment.dev.baseUrl,
                                   headers: [
                                    "platform": "ios",
                                    "version": UIApplication.shared.currentVersion ?? ""
                                   ])
        let apiDataNetwork = NetworkService(config: config)
        return DataTransferService(with: apiDataNetwork)
    }
    
    lazy var imageDataTransferService: DataTransferService = {
        let config = NetworkConfig(baseURL: URL(string: "")!)
        let imagesDataNetwork = NetworkService(config: config)
        return DataTransferService(with: imagesDataNetwork)
    }()
}
