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
		
		scrollToNextBusStop(animated: true)
	}
	
	func scrollToNextBusStop(animated animated: Bool){
		
		var nextStopIndex : Int? = nil
		guard let stops = appDelegate.busController.currentUserBus?.route else {
			return
		}
		
		for (index, stop) in stops.enumerate() {
			if stop.name == appDelegate.busController.currentUserBus?.nextStop.name {
				nextStopIndex = index
				break
			}
		}
		
		guard let index = nextStopIndex else {
			return
		}
		
		self.busStopsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Top, animated: animated)
		
	}
	
	@IBAction func headTouched(sender: AnyObject) {
		scrollToNextBusStop(animated: true)
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
		
		
		guard let stopCell = cell as? RouteStopTableViewCell else {
			return cell
		}
		
		
		stopCell.nameLabel.text = stops[indexPath.row].name
		
		//Put cell on half opacity if the bus stop has already been passed
		if let nextStopIndex = nextStopIndex where indexPath.row < nextStopIndex {
			stopCell.dimSubViews()
		} else {
			stopCell.brightenSubViews()
		}
		
		//Change icons if next stop cell is first or last
		if indexPath.row == nextStopIndex  { // cell is nextStopCell
			if indexPath.row == 0 {
				stopCell.iconImageView.image = UIImage(named: "route-icon-top")
			}
			if indexPath.row == (stops.count - 1) {
				stopCell.iconImageView.image = UIImage(named: "route-icon-next-bottom")
			}
		}
		
		return stopCell
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
		busStopsTableView.reloadData()
	}
}