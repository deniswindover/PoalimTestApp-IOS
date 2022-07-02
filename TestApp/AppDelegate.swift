//
//  AppDelegate.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import UIKit
import DWExt



@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DTIToastCenter.defaultCenter.registerCenter()
        return true
    }

}

