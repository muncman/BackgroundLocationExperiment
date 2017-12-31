//
//  LocationManager.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

let LocationUpdatedNotification = NSNotification.Name("BackLoc.LocationUpdated.Notification")

class LocationManager: NSObject, CLLocationManagerDelegate, URLSessionDelegate {
    
    private let locationManager = CLLocationManager()
    private let persistenceKey = "BackLoc.LocationsKey"
    private let secondsBetweenRecordingUpdates: TimeInterval = 30
    private var lastUpdate = Date.distantPast
    private var session: URLSession?
    
    // MARK: - Lifecycle Methods
    
    override init() {
        super.init()
        
        print("Initializing a Location Manager: \(self)")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // If needed for more detail: ...ForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = kCLDistanceFilterNone // default
        
        // TODO: Also use a timer?
    }
    
    deinit {
        print("Location Manager de-initialized: \(self)")
        session?.invalidateAndCancel()
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
    
    // Note: As configured, this only works while app is in the background, on actual device,
    //       and seems to go to notification center but not be visible.
    private func postUserNotification(loc: CLLocation) {
        let content = UNMutableNotificationContent()
        content.title = "Location Updated"
        content.subtitle = "Again"
        content.body = "\(loc)"
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "\(loc)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error requesting user notification: \(error)")
            }
        }
    }
    
    private func processUpdate(loc: CLLocation) {
        save(loc)
        sendUpdate(loc: loc)
        NotificationCenter.default.post(name: LocationUpdatedNotification, object: loc)
        postUserNotification(loc: loc)
    }
    
    private func sendUpdate(loc: CLLocation) {
        let mode: String
        switch UIApplication.shared.applicationState {
        case .active:
            mode = "Active"
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            makeForegroundNetworkCall(url: urlWithLoc(loc), session: session, mode: mode)
        case .inactive:
            mode = "Inactive"
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            makeForegroundNetworkCall(url: urlWithLoc(loc), session: session, mode: mode)
        default:
            mode = "Background"
            session = URLSession(configuration: .background(withIdentifier: "com.methodup.BackgroundBaby"),
                                 delegate: self,
                                 delegateQueue: nil)
            // No block here, since completion handler blocks are not supported in background sessions.
            let dataTask = session?.dataTask(with: urlWithLoc(loc))
            //print("Sending simple, placeholder network request in background")
            save("Sending background network request at \(Date())")
            dataTask?.resume()
        }
    }
    
    private func urlWithLoc(_ loc: CLLocation) -> URL {
        // Note: limited way to post data in order to attempt to stay within simple background fetch guidelines.
        // Note: Not using SSL for easier debugging of the experiment.
        // TODO: url escaping...
        let urlWithLoc = "http://httpbin.org/anything?lat=\(loc.coordinate.latitude)&long=\(loc.coordinate.longitude)"
        return URL(string: urlWithLoc)!
    }
    
    /** Using completion blocks for foreground requests. */
    private func makeForegroundNetworkCall(url: URL, session: URLSession?, mode: String) {
        let dataTask = session?.dataTask(with: url) { [weak self] data, response, error in
            let responseString: String
            if let error = error {
                responseString = "Error: \(error)"
            } else if let data = data, let response = response as? HTTPURLResponse {
                responseString = "\(response.statusCode) - \(url.absoluteString) - \(String(describing:data.count))"
            } else {
                responseString = "No error or data?"
            }
            self?.save("RESPONSE:  \(mode) - \(responseString) - \(Date())")
        }
        print("Sending simple, placeholder network request in foreground")
        dataTask?.resume()
    }
    
    // MARK: - Location Delegate Methods
    
    // Hit three times at launch. That's basically it in simulator, but actual devices are constantly updating (as configured).
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        // Throttle
        let hasNotBeenLongEnough = lastUpdate.addingTimeInterval(secondsBetweenRecordingUpdates).compare(loc.timestamp) == ComparisonResult.orderedDescending
        if hasNotBeenLongEnough {
            return
        }
        lastUpdate = loc.timestamp
        print("\(loc)")
        processUpdate(loc: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error! \(error)")
        save("Location Error! \(error) at \(Date())")
    }
    
    // MARK: - Session Delegate Methods
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("Background network request finished")
        save("Background: request finished at \(Date())")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Network request invalidated")
        if let error = error {
            print("Network request error: \(error)")
            save("Network request error: \(error) at \(Date())")
        }
    }
    
    // MARK: - Public Methods
    
    // Note: only works on actual device; not in the simulator.
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
        NotificationCenter.default.post(name: LocationUpdatedNotification, object: loc)
    }
    
    /** Naive persistence. */
    private func save(_ responseString: String) {
        var locations: NSMutableOrderedSet
        if let priorLocations = getAllLocations() {
            locations = NSMutableOrderedSet()
            locations.addObjects(from: priorLocations)
            locations.add(responseString)
        } else {
            locations = [responseString]
        }
        let locArray = locations.array
        UserDefaults.standard.set(locArray, forKey: persistenceKey)
        NotificationCenter.default.post(name: LocationUpdatedNotification, object: responseString)
    }
    
}

extension CLLocation {
    
    func shortString() -> String {
        return "Time: \(timestamp) Lat: \(coordinate.latitude) Long: \(coordinate.longitude)"
    }
    
}
