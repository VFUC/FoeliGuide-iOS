//
//  UserDataController.swift
//  FöliGuide
//
//  Created by Jonas on 12/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class UserDataController: NSObject {
	
	private struct Keys {
		static let recentSearches = "recentSearches"
	}
	
	let defaults = NSUserDefaults.standardUserDefaults()
	
	var userData : UserData
	
	override init() {
		
		// Check if settings have been stored in defaults already
		// loadFromDefaults can't be called before super.init()
		if let recentSearchesObject = defaults.objectForKey(Keys.recentSearches),
			let recentSearches = recentSearchesObject as? [String] {
				userData = UserData(recentSearches: recentSearches)
		} else {
			userData = UserData(recentSearches: []) //initialize empty if no defaults saved
		}
		
		super.init()
	}
	
	
	
	
	
	func addRecentSearch(search: String){
		
		if let index = userData.recentSearches.indexOf(search) { // Search already exists in recent searches
			userData.recentSearches.removeAtIndex(index)
		}
		else if userData.recentSearches.count >= Constants.RecentSearchesCount { // Search is a new entry, but search limit reached
			userData.recentSearches.removeLast()
		}
		
		userData.recentSearches.insert(search, atIndex: 0)
		saveToDefaults()
	}
	
	
	
	private func loadFromDefaults() -> UserData? {
		guard let recentSearchesObject = defaults.objectForKey(Keys.recentSearches),
			let recentSearches = recentSearchesObject as? [String] else {
				return nil
		}
		return UserData(recentSearches: recentSearches)
	}
	
	
	private func saveToDefaults(){
		defaults.setObject(userData.recentSearches, forKey: Keys.recentSearches)
		
	}
	
}
