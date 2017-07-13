//
//  AppDelegate.swift
//  FöliGuide
//
//  Created by Jonas on 21/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import CoreLocation
import PermissionScope

protocol BusUpdateDelegate {
	func didUpdateBusData()
}

protocol NetworkEventHandler {
	func handleEvent(_ event: NetworkEvent)
}

protocol ApplicationEventHandler {
	func handleEvent(_ event: ApplicationEvent)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	// MARK: Controllers
	let locationController = LocationController()
	let busController = BusDataController()
	var userDataController = UserDataController()
	
	// MARK: Data
	var busStops : [BusStop]?
	
	
	// MARK: Flags
	var alarmIsSet = false
	var didGetUserLocationOnce = false
	
	
	// MARK: Event Handlers
	var busDataUpdateDelegates = [BusUpdateDelegate]()
	var networkEventHandlers = [NetworkEventHandler]()
	var applicationEventHandlers = [ApplicationEventHandler]()
	
	
	//MARK: Application Cycle
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		
		applicationEventHandlers.append(self)
		
		initialDataLoading()
		
		switch PermissionScope().statusLocationInUse() {
		case .authorized:
			locationController.authorized = true
			locationController.requestLocationUpdate()
		default:
			locationController.authorized = false
		}
		

		return true
	}
	
	func initialDataLoading(){
		if busStops == nil { //Get bus stop data once, if not retrieved yet
			busController.getBusStops { (stops) -> () in
				self.busStops = stops
			}
		}
		
		
		
		self.busController.getBussesOnce({ (busses) -> () in
			guard let busses = busses else { // failure getting busses
				return
			}
			
			// find the bus with the matching vehicleRef
			for bus in busses where bus.vehicleRef == self.busController.currentUserBus?.vehicleRef {
				
				var updatedBus = bus
				
				updatedBus.route = self.busController.currentUserBus?.route
				
				self.busController.currentUserBus = updatedBus
				
				
				for delegate in self.busDataUpdateDelegates {
					delegate.didUpdateBusData()
				}
			}
		})
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		if alarmIsSet {
			callApplicationEvent(.closedAppWithActiveAlarm)
		}
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	
	
	
	
	
	func startBusDataLoop(){
		let refreshInterval = userDataController.userData.refreshDataLessFrequently ? Constants.DataRefreshIntervalLessFrequentlyInSeconds :  Constants.DataRefreshIntervalInSeconds
		
		self.busController.getBussesInLoop(intervalInSeconds: refreshInterval, completionHandler: { (busses) -> () in
			guard let busses = busses else { // failure getting busses
				return
			}
			
			
			// find the bus with the matching vehicleRef
			for bus in busses where bus.vehicleRef == self.busController.currentUserBus?.vehicleRef {
				
				var updatedBus = bus
				updatedBus.route = self.busController.currentUserBus?.route

				
				
				//Check if route is going in wrong direction, needs to be reversed
				if let route = updatedBus.route {
					let oldStopName = self.busController.currentUserBus?.nextStop.name
					let newStopName = updatedBus.nextStop.name
					
					var oldBusStopRouteIndex : Int? = nil
					var newBusStopRouteIndex : Int? = nil
					
					for (index, stop) in route.enumerated() {
						if stop.name == oldStopName {
							oldBusStopRouteIndex = index
						}
						
						if stop.name == newStopName {
							newBusStopRouteIndex = index
						}
					}
					
					// If index of new is < index of old, the bus is moving in the reverse direction of the route => reverse the route
					if let old = oldBusStopRouteIndex, let new = newBusStopRouteIndex, new < old {
						updatedBus.route = updatedBus.route?.reversed()
					}
				}
				
				self.busController.currentUserBus = updatedBus
				
				for delegate in self.busDataUpdateDelegates {
					delegate.didUpdateBusData()
				}
			}
			
		})
	}
	
	func stopBusDataLoop(){
		self.busController.stopRunningLoop()
	}
	
	
	
	
	
	//MARK: Event Handlers
	
	func callNetworkEvent(_ event: NetworkEvent){
		for handler in networkEventHandlers {
			handler.handleEvent(event)
		}
	}
	
	func callApplicationEvent(_ event: ApplicationEvent){
		for handler in applicationEventHandlers {
			handler.handleEvent(event)
		}
	}
	
}

extension AppDelegate : ApplicationEventHandler {
	func handleEvent(_ event: ApplicationEvent) {
		if event == .userLocationDidUpdate {
			didGetUserLocationOnce = true
		}
	}
}

