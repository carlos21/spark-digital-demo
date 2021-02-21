//
//  InstantiableController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import UIKit

protocol InstantiableController: class {
    
    static func instance() -> Self
    static func navigationInstance() -> UINavigationController
}

extension InstantiableController where Self: UIViewController {
    
    static func navigationInstance() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: Self.instance())
        navigation.modalPresentationStyle = .fullScreen
        return navigation
    }
}
