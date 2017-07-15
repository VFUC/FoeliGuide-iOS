//
//  Extensions.swift
//  FöliGuide
//
//  Created by Jonas on 19/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import Foundation

extension String {
	/// NSLocalizedString shorthand
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}
