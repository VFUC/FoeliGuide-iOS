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
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	func start(){
		locationManager.delegate = self
		
		//Check the current location authorization status
		switch CLLocationManager.authorizationStatus() {
		case .NotDetermined: //The user has not given explicit authorization yet
			appDelegate.applicationEventHandler?(.LocationAuthorizationNotDetermined)
			return
			
		case .Denied, .Restricted: //The user has not or can not give authorization
			appDelegate.applicationEventHandler?(.LocationAuthorizationDenied)
			return
			
		case .AuthorizedAlways, .AuthorizedWhenInUse: //Authorized
			appDelegate.applicationEventHandler?(.LocationAuthorizationSuccessful)
		}
		
		guard CLLocationManager.locationServicesEnabled() else { //User disabled location services
			appDelegate.applicationEventHandler?(.LocationServicesDisabled)
			return
		}
		
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = kCLDistanceFilterNone //get notified on any gps movement
		locationManager.requestLocation() // Only once, no continuous update
	}
	
	func requestLocationUpdate() {
		locationManager.requestLocation()
	}
	
}



extension LocationController : CLLocationManagerDelegate {
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		start() //try to start, status check happens in start function
	}
	
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		userLocation = newLocation
		appDelegate.applicationEventHandler?(.UserLocationDidUpdate)
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		//last location = most recent
		guard let newLocation = locations.last else {
			print("[LocationManager] didUpdateLocations failed to provide locations")
			return
		}
		
		userLocation = newLocation
		appDelegate.applicationEventHandler?(.UserLocationDidUpdate)
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("[LocationManager] Error getting location! \(error.debugDescription)")
	}
}


extension LocationController : UserLocationDataSource {
	func getLastStoredUserLocation() -> CLLocation {
		return userLocation
	}
}