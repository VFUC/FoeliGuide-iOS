//
//  BusRouteViewController.swift
//  FöliGuide
//
//  Created by Jonas on 21/03/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusRouteViewController: UIViewController {
	
	@IBOutlet weak var busNumberLabel: UILabel!
	@IBOutlet weak var busStopsTableView: UITableView! {
		didSet {
			busStopsTableView.delegate = self
			busStopsTableView.dataSource = self
		}
	}
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
	
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		
        busNumberLabel.text = appDelegate.busController.currentUserBus?.name ?? ""
		appDelegate.busDataUpdateDelegates.append(self)
    }
}

extension BusRouteViewController : UITableViewDataSource {
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var nextStopIndex : Int? = nil
		guard let stops = appDelegate.busController.currentUserBus?.route where indexPath.row < stops.count else {
			return tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath)
		}
		
		for (index, stop) in stops.enumerate() {
			if stop.name == appDelegate.busController.currentUserBus?.nextStop.name {
				nextStopIndex = index
				break
			}
		}
		
		var reuseIdentifier = "defaultCell" //TODO: make a default cell
		
		switch indexPath.row {
		case 0:
			reuseIdentifier = "firstBusStopCell"
		case 1..<stops.count - 1:
			reuseIdentifier = "middleBusStopCell"
		case stops.count - 1:
			reuseIdentifier = "lastBusStopCell"
		default:
			reuseIdentifier = "defaultCell"
		}
		
		if indexPath.row == nextStopIndex {
			reuseIdentifier = "nextStopCell"
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		
		
		if let stopCell = cell as? RouteStopTableViewCell {
			
			if let nextStopIndex = nextStopIndex where indexPath.row < nextStopIndex {
				stopCell.dimSubViews()
			} else {
				stopCell.brightenSubViews()
			}
			
			stopCell.nameLabel.text = stops[indexPath.row].name
			return stopCell
		}
		
		return cell
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return appDelegate.busController.currentUserBus?.route?.count ?? 0
	}
}

extension BusRouteViewController : UITableViewDelegate {
	
}


extension BusRouteViewController : BusUpdateDelegate {
	func didUpdateBusData() {
		print("[BusRouteVC] bus data did update!")
		busStopsTableView.reloadData()
	}
}