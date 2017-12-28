//
//  AppDelegate.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: LocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            var errorInfo = ""
            if let error = error {
                errorInfo = " Error: \(String(describing: error))"
            }
            print("Request for notifications allowed? \(granted)\(errorInfo)")
        }
        
        if let options = launchOptions, let _ = options[UIApplicationLaunchOptionsKey.location] {
            print("Launched by location")
        }
        locationManager = LocationManager()
        locationManager?.startUpdatingLocation()
        return true
    }

}

