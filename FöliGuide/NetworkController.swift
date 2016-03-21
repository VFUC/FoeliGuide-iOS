//
//  NetworkController.swift
//  FöliGuide
//
//  Created by Jonas on 26/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NetworkController: NSObject {
	
	static var requestActive = false
	static var latestRequest : Request? // Latest request, so it can be cancelled if new one comes in
	
	// Gets bus data from API, calls completionhandler with nil if data invalid
	class func getBusData(completionHandler: JSON? -> ()){
		
		requestActive = true
		
		latestRequest = Alamofire.request(.GET, Constants.API.RealTimeBusURL)
			.responseData { response in
				
				requestActive = false
				
				print(response.request)
				
				guard let apidata = response.data else { //check if data returns nil
					completionHandler(nil)
					return
				}
				
				completionHandler(JSON(data: apidata))
		}
	}
	
	// Gets bus stop data from API, calls completionhandler with nil if data invalid
	class func getBusStopData(completionHandler: JSON? -> ()) {
		
		getJSONData(fromURL: Constants.API.BusStopURL, completionHandler: completionHandler)
	}
	
	class func getRoutesData(completionHandler: JSON? -> ()) {
		
		//TODO: put in constants or retrieve dynamically
		getJSONData(fromURL: "http://data.foli.fi/gtfs/v0/20160304-150630/routes", completionHandler: completionHandler)
	}
	
	class func getTripsData(withRouteID routeID: String, completionHandler: JSON? -> ()) {
		//TODO: put in constants or retrieve dynamically
		getJSONData(fromURL: "http://data.foli.fi/gtfs/v0/20160304-150630/trips/route/\(routeID)", completionHandler: completionHandler)
	}
	
	class func getTripData(withTripID tripID: String, completionHandler: JSON? -> ()) {
		getJSONData(fromURL: "http://data.foli.fi/gtfs/v0/20160304-150630/stop_times/trip/\(tripID)", completionHandler: completionHandler)
	}
	
	class func getJSONData(fromURL url: String, completionHandler: JSON? -> ()){
		Alamofire.request(.GET, url)
			.responseData { response in
				
				print(response.request)

				guard let data = response.data else { //check if data returns nil
					completionHandler(nil)
					return
				}
			
				completionHandler(JSON(data: data))
		}
	}
	
	// Cancel Active (bus data) request, if still running
	class func cancelActiveBusDataRequest() {
		if requestActive {
			latestRequest?.cancel()
		}
	}
}
