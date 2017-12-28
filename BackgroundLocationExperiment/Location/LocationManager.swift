//
//  LocationManager.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

let LocationUpdatedNotification = NSNotification.Name("BackLoc.LocationUpdated.Notification")

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let persistenceKey = "BackLoc.LocationsKey"
    private let secondsBetweenRecordingUpdates: TimeInterval = 60
    private var lastUpdate = Date.distantPast
    
    // MARK: - Lifecycle Methods
    
    override init() {
        super.init()
        
        print("Initializing a Location Manager: \(self)")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = kCLDistanceFilterNone // default
        
        // TODO: Timer (here or app delegate?)
        // TODO: There is much more to do here, later... 
    }
    
    deinit {
        print("Location Manager de-initialized: \(self)")
        locationManager.delegate = nil
    }
    
    // MARK: - Process Methods
    
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
    
    // FIXME: notifications not working
    private func postUserNotification(loc: CLLocation) {
        let content = UNMutableNotificationContent()
        content.title = "Location Updated"
        content.subtitle = "Again"
        content.body = "\(loc)"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // TODO: should not need
        let request = UNNotificationRequest(identifier: "\(loc)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error requesting user notification: \(error)")
            }
            else { print("all good posting notification?!") } // TODO: remove else clause
        }
    }
    
    // MARK: - Delegate Methods
    
    // Hit three times at launch
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        // Throttle
        let hasNotBeenLongEnough = lastUpdate.addingTimeInterval(secondsBetweenRecordingUpdates).compare(loc.timestamp) == ComparisonResult.orderedDescending
        if hasNotBeenLongEnough {
            return
        }
        lastUpdate = loc.timestamp
        
        print("\(loc)")
        save(loc)
        // TODO: play a sound
        postUserNotification(loc: loc)
        NotificationCenter.default.post(name: LocationUpdatedNotification, object: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error! \(error)")
    }
    
    // MARK: - Public Methods
    
    // FIXME: not triggering anything? (maybe a simulator issue? test on actual device)
    public func getCurrentLocation() {
        print("Requesting current location data")
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Persistence Methods
    
    public func getAllLocations() -> Array<Any>? {
        if let priorLocations = UserDefaults.standard.array(forKey: persistenceKey) {
            return priorLocations
        }
        return nil
    }
    
    public func clearOldLocations() {
        UserDefaults.standard.set(nil, forKey: persistenceKey)
    }
    
    /** Naive persistence. */
    private func save(_ loc: CLLocation) {
        var locations: NSMutableOrderedSet
        if let priorLocations = getAllLocations() {
            locations = NSMutableOrderedSet()
            locations.addObjects(from: priorLocations)
            locations.add(loc.shortString())
        } else {
            locations = [loc.shortString()]
        }
        let locArray = locations.array
        UserDefaults.standard.set(locArray, forKey: persistenceKey)
    }
    
}

extension CLLocation {
    
    func shortString() -> String {
        return "Time: \(timestamp) Lat: \(coordinate.latitude) Long: \(coordinate.longitude)"
    }
    
}
