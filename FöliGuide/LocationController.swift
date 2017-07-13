//
//  LocationController.swift
//  FöliGuide
//
//  Created by Jonas on 25/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import CoreLocation



protocol UserLocationDataSource {
	func getLastStoredUserLocation() -> CLLocation
}


class LocationController: NSObject{
	
	var locationManager = CLLocationManager()
	var userLocation = CLLocation()
	
	var authorized = false
	
	override init(){
		super.init()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = kCLDistanceFilterNone //get notified on any gps movement
	}

	func requestLocationUpdate() {
		locationManager.requestLocation()
	}
	
}



extension LocationController : CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse {
			requestLocationUpdate()
		}
	}

	/*
	func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		userLocation = newLocation
		appDelegate.callApplicationEvent(.userLocationDidUpdate)
	}*/
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		//last location = most recent
		guard let newLocation = locations.last else {
			print("[LocationManager] didUpdateLocations failed to provide locations")
			return
		}
		
		userLocation = newLocation
		appDelegate.callApplicationEvent(.userLocationDidUpdate)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("[LocationManager] Error getting location! \(error.localizedDescription)")
	}
}


extension LocationController : UserLocationDataSource {
	func getLastStoredUserLocation() -> CLLocation {
		return userLocation
	}
}
