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
	
	
	func getCurrentRealtimeBusData(completionHandler: JSON? -> () ){
		
		getDataFromAPI { apiData -> () in
			guard let apidata = apiData else { //check if data returns nil
				completionHandler(nil)
				return
			}
	
			let json = JSON(data: apidata)
			completionHandler(json)
		}
	}
	
	
	func getDataFromAPI(completionHandler: NSData? -> () ) {
		Alamofire.request(.GET, Constants.API.RealTimeBusURL)
			.responseData { response in
				print(response.request)
				print(response.response)
				print(response.result)
				completionHandler(response.data)
		}
	}
}
