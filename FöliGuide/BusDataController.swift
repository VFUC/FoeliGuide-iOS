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

class BusDataController: NSObject {
	
	var networkController = NetworkController()
	
	func getCurrentBusData(completionHandler: [Bus]? -> () ){
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
					let nextStopName = vehicle["next_stoppointname"].string {
						
						let bus = Bus(location: CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), name: name, nextStop: BusStop(name: nextStopName, number: nextStopNumber, location: nil), distanceToUser: nil)
						busses.append(bus)
				}
			}
			
			completionHandler(busses)
		}
	}
	
	func getBussesNearLocation(location: CLLocation, count: Int, completionHandler: [Bus]? -> ()){
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
	
	func setDistanceToUserOnBusses(busses: [Bus], location: CLLocation) -> [Bus]{
		var mutable = busses
		
		for (index, bus) in busses.enumerate() {
			mutable[index].distanceToUser = location.distanceFromLocation(bus.location)
		}
		
		return mutable
	}
	
	func isOrderedBeforeByDistanceToUser(bus1: Bus, bus2: Bus) -> Bool {
		return bus1.distanceToUser < bus2.distanceToUser
	}
	

}
