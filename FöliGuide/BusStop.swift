//
//  BusStop.swift
//  FöliGuide
//
//  Created by Jonas on 27/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import Foundation
import CoreLocation

struct BusStop {
	var name: String
	var number: String
	var location: CLLocation?
	var expectedArrival: Date?
}
