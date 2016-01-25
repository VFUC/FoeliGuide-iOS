//
//  LocationController.swift
//  FöliGuide
//
//  Created by Jonas on 25/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject{
	
	var locationManager = CLLocationManager()
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	func start(){
		
		//Check the current location authorization status
		switch CLLocationManager.authorizationStatus() {
		case .NotDetermined: //The user has not given explicit authorization yet
			appDelegate.handleApplicationEvent(.LocationAuthorizationNotDetermined)
			return
			
		case .Denied, .Restricted: //The user has not or can not give authorization
			appDelegate.handleApplicationEvent(.LocationAuthorizationDenied)
			return
			
		case .AuthorizedAlways, .AuthorizedWhenInUse: break //Authorized
		}
		
		guard CLLocationManager.locationServicesEnabled() else { //User disabled location services
			appDelegate.handleApplicationEvent(.LocationServicesDisabled)
			return
		}
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
}





extension LocationController : CLLocationManagerDelegate {

}