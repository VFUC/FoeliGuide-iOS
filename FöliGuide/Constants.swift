//
//  Constants.swift
//  FöliGuide
//
//  Created by Jonas on 26/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import Foundation

struct Constants {
	struct API { //API Endpoint URLS
		static let RealTimeBusURL = "http://data.foli.fi/siri/vm"
		static let BusStopURL = "http://data.foli.fi/siri/sm/"
	}
	
	static let BusStopNameBlacklist = [ "?" ] //Bus stops that won't be displayed
	static let DataRefreshIntervalInSeconds = 10.0 //Time interval to refresh (bus) data from API
	static let RecentSearchesCount = 6 //Number of recent bus stop searches that should be saved
}