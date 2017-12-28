//
//  LocationsTableViewController.swift
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/27/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    private let locMgr = LocationManager()
    
    // TODO: add notification listener...

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
