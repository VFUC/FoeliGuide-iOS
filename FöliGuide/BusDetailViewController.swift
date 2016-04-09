//
//  BusDetailViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

@objc protocol BusDetailViewControllerDelegate {
	optional func didTapHead()
	optional func didSetAlarm(alarmSet: Bool)
	optional func didSelectDestination(destination: String)
}


class BusDetailViewController: UIViewController {

	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var loadingSpinner: ALThreeCircleSpinner!
	@IBOutlet weak var alarmBarButton: UIBarButtonItem!
	
	@IBOutlet weak var busNumberLabel: UILabel!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var subViewController : UIViewController?
	var delegates = [BusDetailViewControllerDelegate]()
	
	var alarmSet = false {
		didSet {
			appDelegate.alarmIsSet = alarmSet
			
			alarmBarButton.image = alarmSet ? UIImage(named: Constants.Assets.Images.AlarmBarButton.Filled) : UIImage(named: Constants.Assets.Images.AlarmBarButton.Outline)
			
			for delegate in delegates {
				delegate.didSetAlarm?(alarmSet)
			}
		}
	}
	
	var destinationStop : String? {
		didSet {
			alarmSet = !(destinationStop == nil)
			
			if let stop = destinationStop {
				for delegate in delegates {
					delegate.didSelectDestination?(stop)
				}
			}
		}
	}
	
	var nextStop : String?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		appDelegate.busDataUpdateDelegates.append(self) // TODO: remove on popping?
		
		self.loadingSpinner.startAnimating()
		busNumberLabel.text = appDelegate.busController.currentUserBus?.name ?? "?"
		
		delegates = [BusDetailViewControllerDelegate]() //Reset delegates

		appDelegate.busController.getBusRoute(forBus: appDelegate.busController.currentUserBus!) { (busStops) -> () in
			
			self.loadingSpinner.stopAnimating()
			
			
			guard busStops != nil else {
				self.loadSubViewController(withIdentifier: "NextStopSubViewController")
				return
			}
			
			self.appDelegate.busController.currentUserBus?.route = busStops
			self.loadSubViewController(withIdentifier: "BusRouteSubViewController")
		}
		
    }
	
	
	override func viewWillDisappear(animated: Bool) {
		if self.isMovingFromParentViewController() && subViewController != nil { //View is being dismissed -> moving back to previous screen
			subViewController!.willMoveToParentViewController(nil)
			subViewController!.view.removeFromSuperview()
			subViewController!.removeFromParentViewController()
		}
	}
	
	
	func loadSubViewController(withIdentifier identifier: String){
		let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		let vc = storyboard.instantiateViewControllerWithIdentifier(identifier)
		subViewController = vc
		
		addChildViewController(vc)
		vc.view.frame = CGRect(x: 0,y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
		containerView.addSubview(vc.view)
		vc.didMoveToParentViewController(self)
	}
	
	
	
	
	@IBAction func didTapHead(sender: UITapGestureRecognizer) {
		for delegate in delegates {
			delegate.didTapHead?()
		}
	}
	
	@IBAction func didTapAlarmButton(sender: UIBarButtonItem) {
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
	
	
	
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let vc = segue.destinationViewController as? DestinationSelectionTableViewController {
			vc.destinationDelegates.append(self)
		}
	}
	
}


extension BusDetailViewController : DestinationSetDelegate {
	func didSetDestination(destination: String) {
		destinationStop = destination
	}
}


extension BusDetailViewController : BusUpdateDelegate {
	func didUpdateBusData() {
		if let newNextStop = appDelegate.busController.currentUserBus?.nextStop.name {
			if nextStop != newNextStop { //Next stop has changed
				nextStop = newNextStop
				
				if newNextStop == destinationStop {
					NotificationController.showNextBusStationNotification(stopName: newNextStop, viewController: self)
					destinationStop = nil
				}
				
				if let afterThatStop = appDelegate.busController.currentUserBus?.afterThatStop?.name where afterThatStop == destinationStop {
					NotificationController.showAfterThatBusStationNotification(stopName: afterThatStop, viewController: self)
				}
			}
		}
		
		
		
		/* if let nextStop = appDelegate.busController.currentUserBus?.nextStop.name {
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
		*/
	}
}