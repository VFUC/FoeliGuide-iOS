//
//  BusRouteViewController.swift
//  FöliGuide
//
//  Created by Jonas on 21/03/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class BusRouteViewController: UIViewController {
	
	@IBOutlet weak var volumeButton: UIButton!
	@IBOutlet weak var busNumberLabel: UILabel!
	@IBOutlet weak var busStopsTableView: UITableView! {
		didSet {
			busStopsTableView.delegate = self
			busStopsTableView.dataSource = self
		}
	}
	@IBOutlet weak var networkActivityIndicator: UIActivityIndicatorView!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
	
	@IBOutlet weak var initialConstraint: NSLayoutConstraint!
	var currentConstraint : NSLayoutConstraint? = nil
	var volumeEnabled = false {
		didSet {
			
			if initialConstraint != nil {
				volumeButton.removeConstraint(initialConstraint)
			}
			
			if currentConstraint != nil {
				volumeButton.removeConstraint(currentConstraint!)
			}
			
			if volumeEnabled {
				volumeButton.setImage(UIImage(named: "ios-volume-high"), for: UIControlState())
				
				
				
				currentConstraint = NSLayoutConstraint(item: volumeButton, attribute: .width, relatedBy: .equal, toItem: volumeButton, attribute: .height, multiplier: 5/4, constant: 0)
				volumeButton.addConstraint(currentConstraint!)
				
				
			} else {
				volumeButton.setImage(UIImage(named: "ios-volume-low"), for: UIControlState())
				
				currentConstraint = NSLayoutConstraint(item: volumeButton, attribute: .width, relatedBy: .equal, toItem: volumeButton, attribute: .height, multiplier: 2/3, constant: 0)
				
				volumeButton.addConstraint(currentConstraint!)
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
	
	func scrollToNextBusStop(animated: Bool){
		
		var nextStopIndex : Int? = nil
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return
		}
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		
		
		for (index, stop) in displayStops.enumerated() {
			if stop.name == appDelegate.busController.currentUserBus?.nextStop.name {
				nextStopIndex = index
				break
			}
		}
		
		guard let index = nextStopIndex else {
			return
		}
		
		self.busStopsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: animated)
		
	}
	
	@IBAction func headTouched(_ sender: AnyObject) {
		scrollToNextBusStop(animated: true)
	}
	
	@IBAction func volumeButtonPressed(_ sender: UIButton) {
		volumeEnabled = !volumeEnabled
	}
	
	
	func hasDuplicateStops(_ stops: [BusStop]) -> Bool {
		for (index, stop) in stops.enumerated() {
			if index - 1  >= 0 {
				if stops[index - 1].name == stop.name {
					return true
				}
			}
		}
		
		return false
	}
	
	func removeFirstDuplicateStop(_ stops: [BusStop]) -> [BusStop]{
		var stopCopy = stops
		for (index, stop) in stopCopy.enumerated() {
			if index - 1  >= 0 {
				if stopCopy[index - 1].name == stop.name {
					stopCopy.remove(at: index)
					return stopCopy
				}
			}
		}
		
		return stopCopy
	}
}





extension BusRouteViewController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var nextStopIndex : Int? = nil
		
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return tableView.dequeueReusableCell(withIdentifier: "defaultBusStopCell", for: indexPath)
		}
		
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		
		guard indexPath.row < displayStops.count else {
			return tableView.dequeueReusableCell(withIdentifier: "defaultBusStopCell", for: indexPath)
		}
		
		let stop = displayStops[indexPath.row]
		
		for (index, stop) in displayStops.enumerated() {
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		
		guard let stopCell = cell as? RouteStopTableViewCell else {
			return cell
		}
		
		stopCell.nameLabel.text = stop.name
		stopCell.alarmImageView.isHidden = !(stop.name == destinationStop)
		
		//Put cell on half opacity if the bus stop has already been passed
		if let nextStopIndex = nextStopIndex, indexPath.row < nextStopIndex {
			stopCell.dimSubViews()
			stopCell.isUserInteractionEnabled = false
		} else {
			stopCell.brightenSubViews()
			stopCell.isUserInteractionEnabled = true
			stopCell.selectionStyle = .none
		}
		
		if let nextStopIndex = nextStopIndex, indexPath.row == nextStopIndex {
			stopCell.isUserInteractionEnabled = false
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let _ = appDelegate.busController.currentUserBus?.route else {
			return 0
		}
		
		displayStops = appDelegate.busController.currentUserBus!.route!
		return displayStops.count
	}
	
	
}

extension BusRouteViewController : UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.row < displayStops.count else {
			return
		}
		
		
		// Already passed bus stops are not selectable
		var nextStopIndex : Int? = nil
		for (index, stop) in displayStops.enumerated() {
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
			
			let alertController = UIAlertController(title: "Remove alarm?", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ -> Void in
				for (index,stop) in self.displayStops.enumerated() {
					if stop.name == self.destinationStop {
						
						if let cell = self.busStopsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RouteStopTableViewCell {
							cell.alarmImageView.isHidden = true
						}
						
					}
				}
				
				self.destinationStop = nil
			}))
			
			present(alertController, animated: true, completion: nil)
		} else {
			var message = "Do you want to set an alarm for \(selectedStop.name)?"
			
			if destinationStop != nil {
				message += "\nThis will overwrite the alarm for \(destinationStop!)"
			}
			
			let alertController = UIAlertController(title: "Set alarm?", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Set", style: .default, handler: { _ -> Void in
				let previousDestinationStop = self.destinationStop
				self.destinationStop = selectedStop.name
				
				//add alarm icon to newly selected alarm
				if let cell = self.busStopsTableView.cellForRow(at: indexPath) as? RouteStopTableViewCell {
					cell.alarmImageView.isHidden = false
				}
				
				//remove alarm icon if previous alarm existed
				if previousDestinationStop != nil {
					for (index,stop) in self.displayStops.enumerated() {
						if stop.name == previousDestinationStop {
							
							if let cell = self.busStopsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RouteStopTableViewCell {
								cell.alarmImageView.isHidden = true
							}
							
						}
					}
				}
				
				
			}))
			
			present(alertController, animated: true, completion: nil)
		}
		
	}
	
	
	
}


extension BusRouteViewController : BusUpdateDelegate {
	func didUpdateBusData() {
		busStopsTableView.reloadData()
		
		if let nextStop = appDelegate.busController.currentUserBus?.nextStop.name {
			SpeechController.announceNextBusStop(nextStop)
			
			if nextStop == destinationStop {
				NotificationController.showNextBusStationNotification(stopName: nextStop, viewController: self)
				destinationStop = nil
			}
		}
		
		
		if let afterThatStop = appDelegate.busController.currentUserBus?.afterThatStop?.name {
			SpeechController.announceFollowingBusStop(afterThatStop)
			
			if afterThatStop == destinationStop {
				NotificationController.showAfterThatBusStationNotification(stopName: afterThatStop, viewController: self)
			}
		}
	}
}


extension BusRouteViewController : NetworkEventHandler {
	func handleEvent(_ event: NetworkEvent) {
		switch event {
		case .busLoadingStarted:
			networkActivityIndicator.startAnimating()
		case .busLoadingFinished:
			networkActivityIndicator.stopAnimating()
		default: break
		}
	}
}
