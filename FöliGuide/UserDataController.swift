//
//  UserDataController.swift
//  FöliGuide
//
//  Created by Jonas on 12/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class UserDataController: NSObject {

    fileprivate struct Keys {
        static let recentSearches = "recentSearches"
        static let refreshDataLessFrequently = "refreshDataLessFrequently"
        static let onlyNotifyOnce = "onlyNotifyOnce"
    }

    let defaults = UserDefaults.standard

    var userData: UserData {
        didSet {
            saveToDefaults()
        }
    }

    override init() {
        // Check if settings have been stored in defaults already
        // loadFromDefaults can't be called before super.init()

        let recentSearches: [String]? = defaults.object(forKey: Keys.recentSearches) as? [String]
        let refreshDataLessFrequently: Bool? = defaults.object(forKey: Keys.refreshDataLessFrequently) as? Bool
        let onlyNotifyOnce: Bool? = defaults.object(forKey: Keys.onlyNotifyOnce) as? Bool

        userData = UserData(recentSearches: recentSearches ?? [], refreshDataLessFrequently: refreshDataLessFrequently ?? false, onlyNotifyOnce: onlyNotifyOnce ?? false) //initialize empty if no defaults saved

        super.init()
    }





    func addRecentSearch(_ search: String) {

        if let index = userData.recentSearches.index(of: search) { // Search already exists in recent searches
            userData.recentSearches.remove(at: index)
        } else if userData.recentSearches.count >= Constants.RecentSearchesCount { // Search is a new entry, but search limit reached
            userData.recentSearches.removeLast()
        }

        userData.recentSearches.insert(search, at: 0)
    }



    fileprivate func loadFromDefaults() -> UserData? {
        let recentSearches: [String]? = defaults.object(forKey: Keys.recentSearches) as? [String]
        let refreshDataLessFrequently: Bool? = defaults.object(forKey: Keys.refreshDataLessFrequently) as? Bool
        let onlyNotifyOnce: Bool? = defaults.object(forKey: Keys.onlyNotifyOnce) as? Bool

        return UserData(recentSearches: recentSearches ?? [], refreshDataLessFrequently: refreshDataLessFrequently ?? false, onlyNotifyOnce: onlyNotifyOnce ?? false) //initialize empty if no defaults saved
    }


    fileprivate func saveToDefaults() {
        defaults.set(userData.recentSearches, forKey: Keys.recentSearches)
        defaults.set(userData.refreshDataLessFrequently, forKey: Keys.refreshDataLessFrequently)
        defaults.set(userData.onlyNotifyOnce, forKey: Keys.onlyNotifyOnce)
    }

}
