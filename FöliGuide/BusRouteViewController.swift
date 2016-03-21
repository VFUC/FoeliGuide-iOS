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
		
		let cell = tableView.dequeueReusableCellWithIdentifier("busStopCell", forIndexPath: indexPath)
		
		if let stops = appDelegate.busController.currentUserBus?.route where indexPath.row < stops.count ,
		let stopCell = cell as? RouteStopTableViewCell
		{
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
	}
}