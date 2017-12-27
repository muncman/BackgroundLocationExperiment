//
//  AppDelegate.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: LocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let options = launchOptions, let _ = options[UIApplicationLaunchOptionsKey.location] {
            print("Launched by location")
        }
        locationManager = LocationManager()
        locationManager?.startUpdatingLocation()
        return true
    }

}

