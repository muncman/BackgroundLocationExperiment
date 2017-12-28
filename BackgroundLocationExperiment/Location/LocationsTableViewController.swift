//
//  LocationsTableViewController.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit
import CoreLocation

class LocationsTableViewController: UITableViewController {
    
    private let locMgr = LocationManager()
    private var locationUpdateObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationUpdateObserver = NotificationCenter.default.addObserver(forName: LocationUpdatedNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            guard let strongSelf = self else { return }
            
            strongSelf.tableView.reloadData() // naive
            let bottom = IndexPath(row: strongSelf.tableView(strongSelf.tableView, numberOfRowsInSection: 0) - 1, section: 0)
            strongSelf.tableView.scrollToRow(at: bottom, at: .none, animated: true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if locationUpdateObserver != nil {
            NotificationCenter.default.removeObserver(locationUpdateObserver!)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let locations = locMgr.getAllLocations() {
            return locations.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        cell.textLabel?.text = "Unknown"
        if let locations = locMgr.getAllLocations() {
            if locations.count > indexPath.row {
                cell.textLabel?.text = "\(locations[indexPath.row])"
            }
        }
        return cell
    }

}
