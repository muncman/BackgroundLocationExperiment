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
            
            self?.lastUpdateLabel.text = "\(Date())"
            self?.lastLocationLabel.text = "\(loc)"
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationUpdateObserver != nil {
            NotificationCenter.default.removeObserver(locationUpdateObserver!)
        }
    }
    
}
