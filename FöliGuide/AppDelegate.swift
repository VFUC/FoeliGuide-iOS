//
//  AppDelegate.swift
//  FöliGuide
//
//  Created by Jonas on 21/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	var locationController: LocationController? //Do not init until main view appeared, because segues might need do be initiated
	var busStops : [BusStop]? {
		didSet {
			if let stops = busStops {
				busStopNames = BusDataController.namesForBusStops(stops)
			}
			
		}
	}
	var busStopNames : [String]?
	var userDataController = UserDataController()
	
	//MARK: VC Adapters
	var mainVC: MainViewController? {
		didSet {
			mainViewControllerDidAppear()
		}
	}
	
	var nextBusStopVC: NextBusStopViewController? {
		didSet {
			busController.runNow()
		}
	}
	var busSelectionVC: BusSelectionCollectionViewController? {
		didSet {
			locationController?.requestLocationUpdate()
		}
	}
	var authorizationVC: AuthorizationRequestViewController?
	let busController = BusDataController()
	
	// MARK: Event Handlers
	var applicationEventHandler: ((ApplicationEvent) -> ())?
	
	
	
	//MARK: Application Cycle
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		applicationEventHandler = handleApplicationEvent
		
		
		//register for local notifications
		application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
		//TODO: check for permissions
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	//	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
	//		let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
	//		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
	//		//TODO: sound?
	//		self.mainVC?.presentViewController(alertController, animated: true, completion: nil)
	//	}
	
	
	
	func mainViewControllerDidAppear(){
		
		if busStops == nil { //Get bus stop data once, if not retrieved yet
			busController.getBusStops { (stops) -> () in
				self.busStops = stops
			}
		}
		
		
		if locationController == nil { //only if not set yet
			
			locationController = LocationController()
			locationController?.start()
		}
		
		
		
		//TODO: Only when displaying next bus stop
		
		self.busController.getBussesInLoop(intervalInSeconds: Constants.DataRefreshIntervalInSeconds, completionHandler: { (busses) -> () in
			guard let busses = busses else { // failure getting busses
				return
			}
			
			// find the bus with the matching vehicleRef
			for bus in busses where bus.vehicleRef == self.busController.currentUserBus?.vehicleRef {
				
				// if busNumber or nextStation has changed, update
				if self.nextBusStopVC?.busNumberLabel.text != bus.name || self.nextBusStopVC?.nextStationNameLabel.text != bus.nextStop.name {
					self.nextBusStopVC?.busNumberLabel.text = bus.name
					self.nextBusStopVC?.finalStationName.text = bus.finalStop
					self.nextBusStopVC?.nextStationNameLabel.text = bus.nextStop.name
					self.nextBusStopVC?.afterThatStationNameLabel.text = bus.afterThatStop?.name ?? "--"
					self.nextBusStopVC?.didUpdateData() // Notify the VC, so it can act on new data if needed
				}
				
			}
			
		})
		
	}
	
	func handleApplicationEvent(event: ApplicationEvent){
		switch event {
			
		case .LocationAuthorizationNotDetermined, .LocationAuthorizationDenied, .LocationServicesDisabled: //TODO: test - can all cases be treated the same? Nope: Denied needs different interaction
			mainVC?.performSegueWithIdentifier("showAuthorizationRequestVC", sender: nil)
		case .LocationAuthorizationSuccessful:
			mainVC?.dismissViewControllerAnimated(true, completion: nil)
		case .UserLocationDidUpdate:
			busSelectionVC?.loadData()
		}
	}
	
}

