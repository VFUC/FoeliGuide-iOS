//
//  NextBusStopViewController.swift
//  FöliGuide
//
//  Created by Jonas on 01/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class NextBusStopViewController: UIViewController {

	@IBOutlet weak var busNumberLabel: UILabel!
	@IBOutlet weak var nextStationNameLabel: UILabel!
	@IBOutlet weak var afterThatStationNameLabel: UILabel!
	@IBOutlet weak var finalStationName: UILabel!
	@IBOutlet weak var selectedBusStationNameLabel: UILabel!
	@IBOutlet weak var selectedBusStationStackView: UIStackView!
	@IBOutlet weak var mainStackView: UIStackView!
	@IBOutlet weak var alarmBarButton: UIBarButtonItem!
	@IBOutlet weak var volumeButton: UIButton!
	@IBOutlet weak var initialConstraint: NSLayoutConstraint!
	@IBOutlet weak var networkActivityIndicator: UIActivityIndicatorView!

	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var currentConstraint : NSLayoutConstraint? = nil
	
	var alarmSet = false {
		didSet {
			if alarmSet {
				mainStackView.addArrangedSubview(selectedBusStationStackView)
				alarmBarButton.image = UIImage(named: Constants.Assets.Images.AlarmBarButton.Filled)
				appDelegate.alarmIsSet = true
			} else {
				mainStackView.removeArrangedSubview(selectedBusStationStackView)
				alarmBarButton.image = UIImage(named: Constants.Assets.Images.AlarmBarButton.Outline)
				appDelegate.alarmIsSet = false
			}
		}
	}
	
	var destinationStop : String? {
		didSet {
			alarmSet = !(destinationStop == nil)
			selectedBusStationNameLabel.text = destinationStop
		}
	}
	
	var volumeEnabled = false {
		didSet {

			volumeButton.removeConstraint(initialConstraint)
			
			if currentConstraint != nil {
				volumeButton.removeConstraint(currentConstraint!)
			}
			
			if volumeEnabled {
				volumeButton.setImage(UIImage(named: "ios-volume-high"), forState: .Normal)
				
				
				
				currentConstraint = NSLayoutConstraint(item: volumeButton, attribute: .Width, relatedBy: .Equal, toItem: volumeButton, attribute: .Height, multiplier: 5/4, constant: 0)
				volumeButton.addConstraint(currentConstraint!)
				
				
			} else {
				volumeButton.setImage(UIImage(named: "ios-volume-low"), forState: .Normal)
				
				currentConstraint = NSLayoutConstraint(item: volumeButton, attribute: .Width, relatedBy: .Equal, toItem: volumeButton, attribute: .Height, multiplier: 2/3, constant: 0)
					
				volumeButton.addConstraint(currentConstraint!)
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		destinationStop = nil
		busNumberLabel.text = ""
		nextStationNameLabel.text = ""
		afterThatStationNameLabel.text = ""
		appDelegate.busDataUpdateDelegates.append(self)
		appDelegate.networkActivityDelegates.append(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	

	
	
	
	
	@IBAction func alarmButtonPressed(sender: UIBarButtonItem) {
		if alarmSet {
			
			let alertController = UIAlertController(title: "Remove Alarm?", message: "Do you want to remove the alarm for \(destinationStop ?? "--")", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Remove", style: .Destructive, handler: { _ -> Void in
				self.destinationStop = nil
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			
			presentViewController(alertController, animated: true, completion: nil)
			
		} else {
			self.performSegueWithIdentifier("showDestinationSelectionVC", sender: nil)
		}
		
	}
	
	@IBAction func volumeButtonPressed(sender: UIButton) {
		volumeEnabled = !volumeEnabled
	}

	// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if let vc = segue.destinationViewController as? DestinationSelectionTableViewController {
			vc.nextStopVC = self
		}
	}
}



// Data has been updated, check if notification is necessary
extension NextBusStopViewController : BusUpdateDelegate {
	func didUpdateBusData(){
		
		guard let bus = appDelegate.busController.currentUserBus else {
			return
		}
		
		
		guard busNumberLabel.text != bus.name || nextStationNameLabel.text != bus.nextStop.name else {
			//Data did not change
			return
		}
		
		busNumberLabel.text = bus.name
		finalStationName.text = bus.finalStop
		nextStationNameLabel.text = bus.nextStop.name
		afterThatStationNameLabel.text = bus.afterThatStop?.name ?? "--"
		
		if nextStationNameLabel.text == afterThatStationNameLabel.text {
			afterThatStationNameLabel.text = "--" //TODO: Hide
		}
		
		
		
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
	}
}


extension NextBusStopViewController : NetworkActivityDelegate {
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
