//
//  NextStopSubViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class NextStopSubViewController: UIViewController {
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	
	@IBOutlet weak var nextStationNameLabel: UILabel!
	@IBOutlet weak var afterThatStationNameLabel: UILabel!
	@IBOutlet weak var selectedBusStationNameLabel: UILabel!
	
	@IBOutlet weak var mainStackView: UIStackView!
	@IBOutlet weak var selectedBusStationStackView: UIStackView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		nextStationNameLabel.text = ""
		afterThatStationNameLabel.text = ""
		appDelegate.busDataUpdateDelegates.append(self)
    }
}

// Data has been updated, check if notification is necessary
extension NextStopSubViewController : BusUpdateDelegate {
	func didUpdateBusData(){
		
		guard let bus = appDelegate.busController.currentUserBus else {
			return
		}
		
		guard let detailVC = self.parentViewController as? BusDetailViewController else {
			print("[NextStopVC] My parent VC is not a busDetailVC (which I expected)")
			return
		}
		
		
		guard detailVC.busNumberLabel.text != bus.name || nextStationNameLabel.text != bus.nextStop.name else {
			//Data did not change
			return
		}
		
//		detailVC.busNumberLabel.text = bus.name
//		finalStationName.text = bus.finalStop
		
		nextStationNameLabel.text = bus.nextStop.name
		afterThatStationNameLabel.text = bus.afterThatStop?.name ?? "--"
		
		afterThatStationNameLabel.hidden = (nextStationNameLabel.text == afterThatStationNameLabel.text) //Hide if both labels are equal
		
		
		/*
		if nextStationNameLabel.text == destinationStop {
			NotificationController.showNextBusStationNotification(stopName: nextStationNameLabel.text!, viewController: self)
			destinationStop = nil
		}
		
		if afterThatStationNameLabel.text == destinationStop {
			NotificationController.showAfterThatBusStationNotification(stopName: afterThatStationNameLabel.text!, viewController: self)
		}
		
		
		if volumeEnabled {
			if let nextStation = nextStationNameLabel.text {
				SpeechController.announceNextBusStop(nextStation)
			}
			
			if let afterThatStation = afterThatStationNameLabel.text {
				SpeechController.announceFollowingBusStop(afterThatStation)
			}
		}
		*/
	}
}

