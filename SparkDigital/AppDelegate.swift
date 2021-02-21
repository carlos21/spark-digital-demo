//
//  AppDelegate.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard !application.isUnitTesting else { return true }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = PhotosViewController.navigationInstance()
        window?.makeKeyAndVisible()
        return true
    }
}

