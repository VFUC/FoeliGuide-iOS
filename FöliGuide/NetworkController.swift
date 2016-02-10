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
	class func getBusData(completionHandler: JSON? -> () ){
		
		requestActive = true
		
		latestRequest = Alamofire.request(.GET, Constants.API.RealTimeBusURL)
			.responseData { response in
				
				requestActive = false
				
				print(response.request)
				print(response.response)
				print(response.result)
				
				guard let apidata = response.data else { //check if data returns nil
					completionHandler(nil)
					return
				}
				
				completionHandler(JSON(data: apidata))
				
				
		}
	}
	
	// Gets bus stop data from API, calls completionhandler with nil if data invalid
	class func getBusStopData(completionHandler: JSON? -> () ) {
		
		Alamofire.request(.GET, Constants.API.BusStopURL)
			.responseData { response in
				
				print(response.request)
				print(response.response)
				print(response.result)
				
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
