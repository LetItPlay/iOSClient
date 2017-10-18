//
//  AppDelegate.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 28/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupAppearence()
        
        return true
    }

    // MARK: - appearence setup
    func setupAppearence() {
        UITabBar.appearance().tintColor = UIColor.vaActive
    }

}

