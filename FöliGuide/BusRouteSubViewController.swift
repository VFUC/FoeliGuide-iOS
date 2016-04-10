//
//  BusRouteSubViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusRouteSubViewController: UIViewController {

	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	// MARK: Outlets
	@IBOutlet weak var busStopsTableView: UITableView! {
		didSet {
			busStopsTableView.delegate = self
			busStopsTableView.dataSource = self
		}
	}
	
	
	// MARK: Data
	var displayStops = [BusStop]() {
		didSet { //remove duplicate stop names in route
			if hasDuplicateStops(displayStops){ //Will be recursively called until no more duplicates
				displayStops = removeFirstDuplicateStop(displayStops)
			}
		}
	}
	var destinationStop : String? = nil
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		appDelegate.busDataUpdateDelegates.append(self)
		scrollToNextBusStop(animated: true)
		
		if let detailVC = parentViewController as? BusDetailViewController {
			detailVC.delegates.append(self)
		}
	}
	
	
	override func willMoveToParentViewController(parent: UIViewController?) {
		if parent == nil {
			for (index, delegate) in appDelegate.busDataUpdateDelegates.enumerate() {
				if let _ = delegate as? BusRouteSubViewController {
					appDelegate.busDataUpdateDelegates.removeAtIndex(index)
				}
			}
		}
	}
	
	
	
	func hasDuplicateStops(stops: [BusStop]) -> Bool {
		for (index, stop) in stops.enumerate() {
			if index - 1  >= 0 {
				if stops[index - 1].name == stop.name {
					return true
				}
			}
		}
		
		return false
	}
	
	func removeFirstDuplicateStop(stops: [BusStop]) -> [BusStop]{
		var stopCopy = stops
		for (index, stop) in stopCopy.enumerate() {
			if index - 1  >= 0 {
				if stopCopy[index - 1].name == stop.name {
					stopCopy.removeAtIndex(index)
					return stopCopy
				}
			}
		}
		
		return stopCopy
	}
	
	
	func scrollToNextBusStop(animated animated: Bool){
		
		var nextStopIndex : Int? = nil
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return
		}
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		
		
		for (index, stop) in displayStops.enumerate() {
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
}


extension BusRouteSubViewController : UITableViewDataSource {
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var nextStopIndex : Int? = nil
		
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return tableView.dequeueReusableCellWithIdentifier("defaultBusStopCell", forIndexPath: indexPath)
		}
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		
		guard indexPath.row < displayStops.count else {
			return tableView.dequeueReusableCellWithIdentifier("defaultBusStopCell", forIndexPath: indexPath)
		}
		
		let stop = displayStops[indexPath.row]
		
		for (index, stop) in displayStops.enumerate() {
			if stop.name == appDelegate.busController.currentUserBus?.nextStop.name {
				nextStopIndex = index
				break
			}
		}
		
		var reuseIdentifier = "defaultBusStopCell"
		
		switch indexPath.row {
		case 0:
			reuseIdentifier = "firstBusStopCell"
		case 1..<displayStops.count - 1:
			reuseIdentifier = "middleBusStopCell"
		case displayStops.count - 1:
			reuseIdentifier = "lastBusStopCell"
		default:
			reuseIdentifier = "defaultBusStopCell"
		}
		
		if indexPath.row == nextStopIndex {
			reuseIdentifier = "nextStopCell"
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		
		guard let stopCell = cell as? RouteStopTableViewCell else {
			return cell
		}
		
		stopCell.nameLabel.text = stop.name
		stopCell.alarmImageView.hidden = !(stop.name == destinationStop)
		
		//Put cell on half opacity if the bus stop has already been passed
		if let nextStopIndex = nextStopIndex where indexPath.row < nextStopIndex {
			stopCell.dimSubViews()
			stopCell.userInteractionEnabled = false
		} else {
			stopCell.brightenSubViews()
			stopCell.userInteractionEnabled = true
			stopCell.selectionStyle = .None
		}
		
		if let nextStopIndex = nextStopIndex where indexPath.row == nextStopIndex {
			stopCell.userInteractionEnabled = false
		}
		
		
		
		//Change icons if next stop cell is first or last
		if indexPath.row == nextStopIndex  { // cell is nextStopCell
			
			if let nextStopArrivalDate = appDelegate.busController.currentUserBus?.nextStop.expectedArrival {
				let intervalInSeconds = nextStopArrivalDate.timeIntervalSinceNow
				let minutes = Int(intervalInSeconds / 60)
				
				stopCell.arrivalDateLabel.text = (minutes <= 0) ? "now" : "in \(minutes) min"
				
			} else {
				stopCell.arrivalDateLabel.text = ""
			}
			
			if indexPath.row == 0 {
				stopCell.iconImageView.image = UIImage(named: "route-icon-top")
			}
			if indexPath.row == (displayStops.count - 1) {
				stopCell.iconImageView.image = UIImage(named: "route-icon-next-bottom")
			}
		}
		
		
		return stopCell
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return 0
		}
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		return displayStops.count
	}
	
}

extension BusRouteSubViewController : UITableViewDelegate {
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard indexPath.row < displayStops.count else {
			return
		}
		
		
		// Already passed bus stops are not selectable
		var nextStopIndex : Int? = nil
		for (index, stop) in displayStops.enumerate() {
			if stop.name == appDelegate.busController.currentUserBus?.nextStop.name {
				nextStopIndex = index
				break
			}
		}
		guard indexPath.row > nextStopIndex else {
			return
		}
		
	}
	
}


extension BusRouteSubViewController : BusUpdateDelegate {
	func didUpdateBusData() {
		busStopsTableView.reloadData()
	}
}


extension BusRouteSubViewController : BusDetailViewControllerDelegate {
	func didTapHead() {
		scrollToNextBusStop(animated: true)
	}
	
	func didSetAlarm(alarmSet: Bool) {
		if alarmSet == false {
			
			if let previousStop = destinationStop { //previously set a stop
				//remove alarm icon
				for (index, stop) in self.displayStops.enumerate() where stop.name == previousStop {
					if let cell = self.busStopsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? RouteStopTableViewCell {
						cell.alarmImageView.hidden = true
					}
				}
			}
			destinationStop = nil
		}
	}
	
	func didSelectDestination(destination: String) {
		
		if let previousStop = destinationStop { //previously set a stop
			//remove alarm icon
			for (index, stop) in self.displayStops.enumerate() where stop.name == previousStop {
				if let cell = self.busStopsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? RouteStopTableViewCell {
					cell.alarmImageView.hidden = true
				}
			}
		}
		
		
		//set alarm icon on selected alarm
		for (index, stop) in self.displayStops.enumerate() where stop.name == destination {
			if let cell = self.busStopsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? RouteStopTableViewCell {
				cell.alarmImageView.hidden = false
			}
		}
		
		destinationStop = destination
	}
}
