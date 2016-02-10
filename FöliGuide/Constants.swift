//
//  Constants.swift
//  FöliGuide
//
//  Created by Jonas on 26/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import Foundation

struct Constants {
	struct API {
		static let RealTimeBusURL = "http://data.foli.fi/siri/vm"
		static let BusStopURL = "http://data.foli.fi/siri/sm/"
	}
	
	static let BusStopNameBlacklist = [ "?" ]
	static let DataRefreshIntervalInSeconds = 10.0
}