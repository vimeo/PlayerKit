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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = PlayerViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
