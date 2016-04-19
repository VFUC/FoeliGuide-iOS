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
	@IBOutlet weak var alarmBarButton: UIBarButtonItem! {
		didSet {
			alarmBarButton.accessibilityLabel = "Set an alarm".localized
		}
	}
	
	@IBOutlet weak var volumeButton: UIButton! {
		didSet {
			volumeButton.imageView?.contentMode = .ScaleAspectFit
		}
	}
	
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
				didNotifyUserAboutUpcomingDestination = false
				for delegate in delegates {
					delegate.didSelectDestination?(stop)
				}
			}
		}
	}
	
	var volumeEnabled = false {
		didSet {
			volumeButton.accessibilityLabel = volumeEnabled ? "Turn off announcements".localized : "Turn on announcements".localized
			
			if volumeEnabled {
				volumeButton.setImage(UIImage(named: "ios-volume-high"), forState: .Normal)
				
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
					self.announceNextTwoBusStops()
				})
				
			} else {
				SpeechController.stopSpeaking()
				volumeButton.setImage(UIImage(named: "ios-volume-low"), forState: .Normal)
			}
		}
	}
	
	var didNotifyUserAboutUpcomingDestination = false //Used when user wants to be notified only once
	
	var nextStop : String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		appDelegate.busDataUpdateDelegates.append(self)
		
		loadingSpinner.startAnimating()
		busNumberLabel.text = appDelegate.busController.currentUserBus?.name ?? "?"
		
		volumeEnabled = false

		delegates = [BusDetailViewControllerDelegate]() //Reset delegates
		
		appDelegate.networkEventHandlers.append(self)
		appDelegate.applicationEventHandlers.append(self)
		
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
	
	
	override func viewDidDisappear(animated: Bool) {
		if self.isMovingFromParentViewController() && subViewController != nil { //View is being dismissed -> moving back to previous screen
			subViewController!.willMoveToParentViewController(nil)
			subViewController!.view.removeFromSuperview()
			subViewController!.removeFromParentViewController()
			
			volumeEnabled = false
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
	
	
	func announceNextTwoBusStops(){
		if let nextStation = appDelegate.busController.currentUserBus?.nextStop.name {
			SpeechController.announceNextBusStop(nextStation)
		}
		
		if let afterThatStation = appDelegate.busController.currentUserBus?.afterThatStop?.name {
			SpeechController.announceFollowingBusStop(afterThatStation)
		}
	}
	
	func showNetworkErrorAlert(){
		let vc = UIAlertController(title: "Network Error", message: "Please check your internet connection", preferredStyle: .Alert)
		vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (_) in
			vc.removeFromParentViewController()
		}))
		presentViewController(vc, animated: true, completion: nil)
	}
	
	func showAppClosedWithActiveAlarmAlert(){
		let vc = UIAlertController(title: "Alarm will not ring when app is closed", message: "In order to accurately determine where your bus is, the app loads data from the Föli servers several times a minute. If you close the app, it is not possible to check frequently enough anymore.", preferredStyle: .Alert)
		vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (_) in
			vc.removeFromParentViewController()
		}))
		presentViewController(vc, animated: true, completion: nil)
	}
	
	
	@IBAction func didTapHead(sender: UITapGestureRecognizer) {
		for delegate in delegates {
			delegate.didTapHead?()
		}
	}
	
	@IBAction func didTapAlarmButton(sender: UIBarButtonItem) {
		if alarmSet {
			
			let title = NSLocalizedString("Remove alarm?", comment: "Asking the user if he's sure to remove the alarm")
			let message = String.localizedStringWithFormat(NSLocalizedString("Do you want to remove the alarm for %@?", comment: "Name the bus station the user is about to delete the alarm for"), (destinationStop ?? "--"))
			
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove button label"), style: .Destructive, handler: { _ -> Void in
				self.destinationStop = nil
			}))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button label"), style: .Cancel, handler: nil))
			
			presentViewController(alertController, animated: true, completion: nil)
			
		} else {
			self.performSegueWithIdentifier("showDestinationSelectionVC", sender: nil)
		}
	}
	
	@IBAction func didTapVolumeButton(sender: UIButton) {
		volumeEnabled = !volumeEnabled
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
				
				if volumeEnabled {
					announceNextTwoBusStops()
				}
				
				if newNextStop == destinationStop {
					
					if !appDelegate.userDataController.userData.onlyNotifyOnce ||  (appDelegate.userDataController.userData.onlyNotifyOnce && !didNotifyUserAboutUpcomingDestination ) {
						NotificationController.showNextBusStationNotification(stopName: newNextStop, viewController: self)
						didNotifyUserAboutUpcomingDestination = true
					}
					
					destinationStop = nil
				}
				
				if let afterThatStop = appDelegate.busController.currentUserBus?.afterThatStop?.name where afterThatStop == destinationStop {
					
					if !appDelegate.userDataController.userData.onlyNotifyOnce ||  (appDelegate.userDataController.userData.onlyNotifyOnce && !didNotifyUserAboutUpcomingDestination ) {
						NotificationController.showAfterThatBusStationNotification(stopName: afterThatStop, viewController: self)
						didNotifyUserAboutUpcomingDestination = true
					}
				}
				
			}//next stop has changed
		}
		
		
	}
}

extension BusDetailViewController : ApplicationEventHandler {
	func handleEvent(event: ApplicationEvent) {
		if event == .ClosedAppWithActiveAlarm {
			showAppClosedWithActiveAlarmAlert()
		}
	}
}

extension BusDetailViewController : NetworkEventHandler {
	func handleEvent(event: NetworkEvent) {
		switch event {
		case .LoadingFailed:
			showNetworkErrorAlert()
		default:
			break
		}
	}
}
