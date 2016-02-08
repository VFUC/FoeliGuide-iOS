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

class BusByLocationLoopParameters {
	var locationSource: UserLocationDataSource
	var count: Int
	var completionHandler: [Bus]? -> ()
	
	init(locationSource: UserLocationDataSource, count: Int, completionHandler: ([Bus]? -> ())){
		self.locationSource = locationSource
		self.count = count
		self.completionHandler = completionHandler
	}
}

class BusLoopParameters {
	var completionHandler: [Bus]? -> ()
	
	init(completionHandler: ([Bus]? -> ())){
		self.completionHandler = completionHandler
	}
}

class BusDataController: NSObject {
	
	private var timer: NSTimer? = nil
	var currentUserBus : Bus = Bus(vehicleRef: "60043", location: CLLocation(latitude: CLLocationDegrees(60.407118), longitude: CLLocationDegrees(22.319192)), name: "7", nextStop: BusStop(name: "nextStop", number: "Num", location: nil), distanceToUser: nil)
	
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
					let vehicleRef = vehicle["vehicleref"].string {
						
						let bus = Bus(vehicleRef: vehicleRef, location: CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), name: name, nextStop: BusStop(name: nextStopName, number: nextStopNumber, location: nil), distanceToUser: nil)
						busses.append(bus)
				}
			}
			
			completionHandler(busses)
		}
	}
	
	private func getBussesNearLocation(location: CLLocation, count: Int, completionHandler: [Bus]? -> ()){
		getCurrentBusData { (busses) -> () in
			
			guard let busses = busses else {
				completionHandler(nil)
				return
			}
			
			let bussesWithDistance = self.setDistanceToUserOnBusses(busses, location: location)
			
			let sorted = bussesWithDistance.sort(self.isOrderedBeforeByDistanceToUser)
			
			completionHandler(Array(sorted[0..<count]))
		}
	}
	
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
	
	
	func runNow(){
		self.timer?.fire()
	}
	
	
	func stopRunningLoop(){
		guard let timer = timer else {
			print("[BusDataController] Trying to stop a timer that has not been set anyways")
			return
		}
		
		timer.invalidate()
		self.timer = nil
	}
	
	
	
	func getBussesInLoop(intervalInSeconds intervalInSeconds: Double, completionHandler: [Bus]? -> ()){
		guard timer == nil else {
			print("[BusDataController] Timer is set -> not starting again")
			return
		}
		
		let parameters = BusLoopParameters(completionHandler: completionHandler)
		
		timer = NSTimer.scheduledTimerWithTimeInterval(intervalInSeconds, target: self, selector: "getBussesLoop:", userInfo: parameters, repeats: true)
		timer?.fire() // start right away
	}
	
	func getBussesLoop(timer: NSTimer) {
		guard let parameters = timer.userInfo as? BusLoopParameters else {
			print("[BusDataController] Sending parameter of unrecognized type to busLoop")
			return
		}
		
		NetworkController.cancelActiveRequest() // in case a request is still running
		
		getCurrentBusData(parameters.completionHandler)
	}
	
	
	
	

	// Location must be passed via data source, so it can be dynamically updated.
	// Passing the location directly would call the loop with the same parameter each time
	func getNearbyBussesInLoopFromLocationDataSource(source: UserLocationDataSource, count: Int, intervalInSeconds: Double, completionHandler: [Bus]? -> ()){
		guard timer == nil else {
			print("[BusDataController] Timer is set -> not starting again")
			return
		}
		
		let parameters = BusByLocationLoopParameters(locationSource: source, count: count, completionHandler: completionHandler)
		
		timer = NSTimer.scheduledTimerWithTimeInterval(intervalInSeconds, target: self, selector: "getNearbyBussesLoop:", userInfo: parameters, repeats: true)
		timer?.fire() // start right away
	}
	
	// Method, which is repeadetly called while loop is running
	func getNearbyBussesLoop(timer: NSTimer) {
		guard let parameters = timer.userInfo as? BusByLocationLoopParameters else {
			print("[BusDataController] Sending parameter of unrecognized type to busLoop")
			return
		}
		
		NetworkController.cancelActiveRequest() // in case a request is still running
		
		getBussesNearLocation(parameters.locationSource.getLastStoredUserLocation(), count: parameters.count, completionHandler: parameters.completionHandler)
	}
	
	

}
