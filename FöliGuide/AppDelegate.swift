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
	var loopRunning = false
	var busStops : [BusStop]? {
		didSet {
			if let stops = busStops {
				busStopNames = namesForBusStops(stops)
			}
			
		}
	}
	var busStopNames : [String]?
	
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
	var authorizationVC: AuthorizationRequestViewController?
	let busController = BusDataController()
	
	// MARK: Event Handlers
	var applicationEventHandler: ((ApplicationEvent) -> ())?
	var	userLocationUpdateHandler: ((CLLocation) -> ())?

	
	

	//MARK: Application Cycle
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		applicationEventHandler = handleApplicationEvent
		
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
	
	
	
	func mainViewControllerDidAppear(){
		if locationController == nil { //only if not set yet
			locationController = LocationController()
			locationController?.start()
			
			
			if let locationController = self.locationController {
				userLocationUpdateHandler = { [unowned self](location: CLLocation) in
					if !self.loopRunning { //only start once, not on every user location update
						
						self.busController.getBussesInLoop(intervalInSeconds: 10, completionHandler: { (busses) -> () in
							guard let busses = busses else { // failure getting busses
								return
							}
							
							for bus in busses where bus.vehicleRef == self.busController.currentUserBus?.vehicleRef {
								self.nextBusStopVC?.busNumberLabel.text = bus.name
								self.nextBusStopVC?.nextStationNameLabel.text = bus.nextStop.name
							}
							
						})
						
						
						/*
						self.busController.getBussesInLoopFromLocationDataSource(locationController, count: 1, intervalInSeconds: 10, completionHandler: { (busses) -> () in
							
							guard let busses = busses else { // failure getting busses
								return
							}
							
							if busses.count > 0 {
								self.nextBusStopVC?.busNumberLabel.text = busses[0].name
								self.nextBusStopVC?.nextStationNameLabel.text = busses[0].nextStop.name
								
								if let distance = busses[0].distanceToUser {
									self.nextBusStopVC?.busDistanceDebugLabel.text = "Distance to bus: \(Int(distance))m"
								} else {
									self.nextBusStopVC?.busDistanceDebugLabel.text = "Distance to bus unknown"
								}
								
								
							}
						})
						*/
						
						self.loopRunning = true
					}
				}
			}
		}
		
		if busStops == nil {
			busController.getBusStops { (stops) -> () in
				self.busStops = stops
			}
		}
	}
	
	func handleApplicationEvent(event: ApplicationEvent){
		switch event {
			
		case .LocationAuthorizationNotDetermined, .LocationAuthorizationDenied, .LocationServicesDisabled: //TODO: test - can all cases be treated the same? Nope: Denied needs different interaction
			mainVC?.performSegueWithIdentifier("showAuthorizationRequestVC", sender: nil)
		case .LocationAuthorizationSuccessful:
			mainVC?.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	
	func namesForBusStops(stops: [BusStop]) -> [String] {
		var names = Set<String>()
		
		for stop in stops {
			if Constants.BusStopNameBlacklist.contains(stop.name){
				continue
			}
			
			names.insert(stop.name)
		}
		
		return Array(names)
	}

}

