//
//  LocationInfo.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/28/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationInfo {
    
    let lat: CLLocationCoordinate2D
    let long: CLLocationCoordinate2D
    let timestamp: Date
    
    init(lat: CLLocationCoordinate2D, long: CLLocationCoordinate2D, timestamp: Date) {
        self.lat = lat
        self.long = long
        self.timestamp = timestamp
    }
}
