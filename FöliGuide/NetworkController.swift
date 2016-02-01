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
	static var latestRequest : Request?
	
	class func getCurrentRealtimeBusData(completionHandler: JSON? -> () ){
		
		getDataFromAPI { apiData -> () in
			guard let apidata = apiData else { //check if data returns nil
				completionHandler(nil)
				return
			}
			
			let json = JSON(data: apidata)
			completionHandler(json)
		}
	}
	
	
	private class func getDataFromAPI(completionHandler: NSData? -> () ) {
		requestActive = true
		
		latestRequest = Alamofire.request(.GET, Constants.API.RealTimeBusURL)
			.responseData { response in
				
				requestActive = false
				
				print(response.request)
				print(response.response)
				print(response.result)
				completionHandler(response.data)
		}
	}
	
	
	class func cancelActiveRequest() {
		if requestActive {
			latestRequest?.cancel()
		}
	}
}
