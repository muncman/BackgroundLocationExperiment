//
//  LocationManager.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle Methods
    
    override init() {
        super.init()
        
        print("Initializing a LocationManager")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = kCLDistanceFilterNone // default
    }
    
    deinit {
        print("Location Manager de-initialized: \(self)")
        locationManager.delegate = nil
    }
    
    // MARK: Process Methods
    
    func startUpdatingLocation() {
        let auth = CLLocationManager.authorizationStatus()
        if auth == .denied {
            print("Location Services permissions are disabled")
        } else {
            print("Starting to monitor location updates")
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            print("\(loc)")
        }
    }
    
}
