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
		static let BusStopURL = "http://data.foli.fi/siri/sm"
		static let GTFSInfoURL = "http://data.foli.fi/gtfs"
	}
	
	static let BusStopNameBlacklist = [ "?" ] //Bus stops that won't be displayed
	static let DataRefreshIntervalInSeconds = 7.0 //Time interval to refresh (bus) data from API
	static let DataRefreshIntervalLessFrequentlyInSeconds = 15.0 //Used when user selects "refresh less often" setting
	static let RecentSearchesCount = 6 //Number of recent bus stop searches that should be saved
	
	struct Assets {
		struct Images {
			struct AlarmBarButton {
				static let Outline = "bell"
				static let Filled = "bell-filled"
			}
		}
	}
}