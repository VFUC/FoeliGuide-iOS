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
		static let refreshDataLessFrequently = "refreshDataLessFrequently"
		static let onlyNotifyOnce = "onlyNotifyOnce"
	}
	
	let defaults = NSUserDefaults.standardUserDefaults()
	
	var userData : UserData {
		didSet {
			saveToDefaults()
		}
	}
	
	override init() {
		// Check if settings have been stored in defaults already
		// loadFromDefaults can't be called before super.init()
		
		let recentSearches : [String]? = defaults.objectForKey(Keys.recentSearches) as? [String]
		let refreshDataLessFrequently : Bool? = defaults.objectForKey(Keys.refreshDataLessFrequently) as? Bool
		let onlyNotifyOnce : Bool? = defaults.objectForKey(Keys.onlyNotifyOnce) as? Bool

		userData = UserData(recentSearches: recentSearches ?? [], refreshDataLessFrequently: refreshDataLessFrequently ?? false, onlyNotifyOnce: onlyNotifyOnce ?? false) //initialize empty if no defaults saved
		
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
	}
	
	
	
	private func loadFromDefaults() -> UserData? {
		let recentSearches : [String]? = defaults.objectForKey(Keys.recentSearches) as? [String]
		let refreshDataLessFrequently : Bool? = defaults.objectForKey(Keys.refreshDataLessFrequently) as? Bool
		let onlyNotifyOnce : Bool? = defaults.objectForKey(Keys.onlyNotifyOnce) as? Bool
		
		return UserData(recentSearches: recentSearches ?? [], refreshDataLessFrequently: refreshDataLessFrequently ?? false, onlyNotifyOnce: onlyNotifyOnce ?? false) //initialize empty if no defaults saved
	}
	
	
	private func saveToDefaults(){
		defaults.setObject(userData.recentSearches, forKey: Keys.recentSearches)
		defaults.setObject(userData.refreshDataLessFrequently, forKey: Keys.refreshDataLessFrequently)
		defaults.setObject(userData.onlyNotifyOnce, forKey: Keys.onlyNotifyOnce)
	}
	
}
