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
	@IBOutlet weak var networkActivityIndicator: UIActivityIndicatorView!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var displayStops = [BusStop]() {
		
		didSet {
			//remove duplicate stop names in route
			if hasDuplicateStops(displayStops){ //Will be recursively called until no more duplicates
				displayStops = removeFirstDuplicateStop(displayStops)
			}
		}
	}
	
	
	var alarmSet = false {
		didSet {
			if alarmSet {
				appDelegate.alarmIsSet = true
			} else {
				appDelegate.alarmIsSet = false
			}
		}
	}
	
	var destinationStop : String? {
		didSet {
			alarmSet = !(destinationStop == nil)
		}
	}
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		busNumberLabel.text = appDelegate.busController.currentUserBus?.name ?? ""
		appDelegate.busDataUpdateDelegates.append(self)
		appDelegate.networkEventHandlers.append(self)
		
		scrollToNextBusStop(animated: true)
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
	
	@IBAction func headTouched(sender: AnyObject) {
		scrollToNextBusStop(animated: true)
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
}





extension BusRouteViewController : UITableViewDataSource {
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

extension BusRouteViewController : UITableViewDelegate {
	
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
		
		
		
		
		let selectedStop = displayStops[indexPath.row]
		
		if selectedStop.name == destinationStop {
			let message = "Do you want to remove the alarm for \(selectedStop.name)?"
			
			let alertController = UIAlertController(title: "Remove alarm?", message: message, preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Remove", style: .Destructive, handler: { _ -> Void in
				for (index,stop) in self.displayStops.enumerate() {
					if stop.name == self.destinationStop {
						
						if let cell = self.busStopsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? RouteStopTableViewCell {
							cell.alarmImageView.hidden = true
						}
						
					}
				}
				
				self.destinationStop = nil
			}))
			
			presentViewController(alertController, animated: true, completion: nil)
		} else {
			var message = "Do you want to set an alarm for \(selectedStop.name)?"
			
			if destinationStop != nil {
				message += "\nThis will overwrite the alarm for \(destinationStop!)"
			}
			
			let alertController = UIAlertController(title: "Set alarm?", message: message, preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Set", style: .Default, handler: { _ -> Void in
				let previousDestinationStop = self.destinationStop
				self.destinationStop = selectedStop.name
				
				//add alarm icon to newly selected alarm
				if let cell = self.busStopsTableView.cellForRowAtIndexPath(indexPath) as? RouteStopTableViewCell {
					cell.alarmImageView.hidden = false
				}
				
				//remove alarm icon if previous alarm existed
				if previousDestinationStop != nil {
					for (index,stop) in self.displayStops.enumerate() {
						if stop.name == previousDestinationStop {
							
							if let cell = self.busStopsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? RouteStopTableViewCell {
								cell.alarmImageView.hidden = true
							}
							
						}
					}
				}
				
				
			}))
			
			presentViewController(alertController, animated: true, completion: nil)
		}
		
	}
	
	
	
}


extension BusRouteViewController : BusUpdateDelegate {
	func didUpdateBusData() {
		busStopsTableView.reloadData()
		
		if let nextStop = appDelegate.busController.currentUserBus?.nextStop where nextStop.name == destinationStop{
			NotificationController.showNextBusStationNotification(stopName: destinationStop!, viewController: self)
			destinationStop = nil
		}
		
		
		if let afterThatStop = appDelegate.busController.currentUserBus?.afterThatStop where afterThatStop.name == destinationStop{
			NotificationController.showAfterThatBusStationNotification(stopName: destinationStop!, viewController: self)
			destinationStop = nil
		}
	}
}


extension BusRouteViewController : NetworkEventHandler {
	func handleEvent(event: NetworkEvent) {
		switch event {
		case .BusLoadingStarted:
			networkActivityIndicator.startAnimating()
		case .BusLoadingFinished:
			networkActivityIndicator.stopAnimating()
		default: break
		}
	}
}