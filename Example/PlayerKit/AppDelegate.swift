//
//  AppDelegate.swift
//  PlayerKit
//
//  Created by ghking on 03/07/2017.
//  Copyright (c) 2017 ghking. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = PlayerViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
