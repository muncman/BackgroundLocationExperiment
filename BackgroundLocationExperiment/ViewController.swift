//
//  ViewController.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet private weak var lastLocationLabel: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    private var locationUpdateObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationUpdateObserver = NotificationCenter.default.addObserver(forName: LocationUpdatedNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            
            guard let loc = notification.object as? CLLocation else { return }
            
            self?.updateLabels(for: loc)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationUpdateObserver != nil {
            NotificationCenter.default.removeObserver(locationUpdateObserver!)
        }
    }
    
    // MARK: - Interface Methods
    
    private func updateLabels(for loc: CLLocation) {
        lastUpdateLabel.text = "\(Date())"
        lastLocationLabel.text = "\(loc)"
    }
    
    // MARK: - Action Methods
    
    @IBAction func getLocation() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let locMgr = appDelegate.locationManager
        locMgr?.getCurrentLocation()
    }
    
    @IBAction func clearLocations() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let locMgr = appDelegate.locationManager
        locMgr?.clearOldLocations()
    }
    
}
