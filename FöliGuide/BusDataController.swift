//
//  BusDataController.swift
//  FöliGuide
//
//  Created by Jonas on 27/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON


// Used to pass parameters to the bus data retrieval loop
class BusLoopParameters {
	var completionHandler: [Bus]? -> ()
	
	init(completionHandler: ([Bus]? -> ())){
		self.completionHandler = completionHandler
	}
}


class BusDataController: NSObject {
	
	private var timer: NSTimer? = nil // used for running network loop
	var currentUserBus : Bus? = nil // current bus the user has selected
	var currentBusData : [Bus]? // last saved bus data
	
	private func getCurrentBusData(completionHandler: [Bus]? -> () ){
		NetworkController.getCurrentRealtimeBusData { (json) -> () in
			
			guard let json = json else {
				completionHandler(nil)
				return
			}
			
			guard let vehicles = json["result"]["vehicles"].dictionary else {
				completionHandler(nil)
				return
			}
			
			var busses = [Bus]()
			
			for (_, vehicle) in vehicles {
				if let name = vehicle["lineref"].string,
					let longitude = vehicle["longitude"].float,
					let latitude = vehicle["latitude"].float,
					let nextStopNumber = vehicle["next_stoppointref"].string,
					let nextStopName = vehicle["next_stoppointname"].string,
					let vehicleRef = vehicle["vehicleref"].string,
					let finalStop = vehicle["destinationname"].string
				{
						
					let nextStop = BusStop(name: nextStopName, number: nextStopNumber, location: nil)
					var afterThatStop : BusStop? = nil
					
					if let onwardCalls = vehicle["onwardcalls"].array where onwardCalls.count > 0 {
						if let name = onwardCalls[0]["stoppointname"].string,
						let number = onwardCalls[0]["visitnumber"].int {
							afterThatStop = BusStop(name: name, number: "\(number)", location: nil)
						}
					}
					
						
					let bus = Bus(vehicleRef: vehicleRef, location: CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), name: name, nextStop: nextStop, afterThatStop: afterThatStop, finalStop: finalStop, distanceToUser: nil)
						busses.append(bus)
				}
			}
			
			self.currentBusData = busses
			completionHandler(busses)
		}
	}
	
	// Gets the current bus stop data
	func getBusStops(completionHandler completionHandler: [BusStop]? -> ()){
		NetworkController.getBusStopData { (json) -> () in
			guard let json = json else {
				completionHandler(nil)
				return
			}
			
			guard let dict = json.dictionary else {
				completionHandler(nil)
				return
			}
			
			var stops = [BusStop]()
			
			for (key, value) in dict { //key: station number, value: dict{ "stop_name": name }
				if let name = value["stop_name"].string {
					stops.append(BusStop(name: name, number: key, location: nil))
				}
			}
			
			completionHandler(stops)
		}
	}
	
	
	// Sets the distance to the user property on all the input busses
	private func setDistanceToUserOnBusses(busses: [Bus], location: CLLocation) -> [Bus]{
		var mutable = busses
		
		for (index, bus) in busses.enumerate() {
			mutable[index].distanceToUser = location.distanceFromLocation(bus.location)
		}
		
		return mutable
	}
	
	private func isOrderedBeforeByDistanceToUser(bus1: Bus, bus2: Bus) -> Bool {
		return bus1.distanceToUser < bus2.distanceToUser
	}
	
	// Runs loop action immediately (if timer set)
	func runNow(){
		self.timer?.fire()
	}
	
	// Stops the currently running loop
	func stopRunningLoop(){
		guard let timer = timer else {
			print("[BusDataController] Trying to stop a timer that has not been set anyways")
			return
		}
		
		timer.invalidate()
		self.timer = nil
	}
	
	
	// Periodically retrieves bus data
	func getBussesInLoop(intervalInSeconds intervalInSeconds: Double, completionHandler: [Bus]? -> ()){
		guard timer == nil else {
			print("[BusDataController] Timer is set -> not starting again")
			return
		}
		
		let parameters = BusLoopParameters(completionHandler: completionHandler)
		
		timer = NSTimer.scheduledTimerWithTimeInterval(intervalInSeconds, target: self, selector: "getBussesLoop:", userInfo: parameters, repeats: true)
		timer?.fire() // start right away
	}
	
	
	// Function used in timer loop to periodically retrieve bus data, arguments passed via BusLoopParameter struct
	func getBussesLoop(timer: NSTimer) {
		guard let parameters = timer.userInfo as? BusLoopParameters else {
			print("[BusDataController] Sending parameter of unrecognized type to busLoop")
			return
		}
		
		NetworkController.cancelActiveRequest() // in case a request is still running
		
		getCurrentBusData(parameters.completionHandler)
	}
	
	
	
	
	
	// Returns input bus array, sorted by distance to user
	func sortBussesByDistanceToUser(busses busses: [Bus], userLocation: CLLocation) -> [Bus] {
		let bussesWithDistance = setDistanceToUserOnBusses(busses, location: userLocation)
		
		let sorted = bussesWithDistance.sort(self.isOrderedBeforeByDistanceToUser)
		
		return Array(sorted)
	}
	
	
	
}
