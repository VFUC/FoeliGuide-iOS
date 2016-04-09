//
//  DestinationSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 08/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

protocol DestinationSetDelegate {
	func didSetDestination(destination: String)
}


class DestinationSelectionTableViewController: UITableViewController {
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	var busStopNames = [String]() {
		didSet {
			if !routeDataAvailable {
				busStopNames.sortInPlace( { $0 < $1 } )
			}
		}
	}
	var recentSearchEntries = [String]()
	
	var filteredRecentSearchEntries = [String]()
	var filteredBusStopNames = [String]()
	
	var destinationDelegates = [DestinationSetDelegate]()
	var routeDataAvailable = false
	
	let searchController = UISearchController(searchResultsController: nil)
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let route = appDelegate.busController.currentUserBus?.route {
			routeDataAvailable = true
			busStopNames = BusDataController.namesForBusStops(route, preserveOrder: true)
		} else if let delegateStops = appDelegate.busStops {
			routeDataAvailable = false
			busStopNames = BusDataController.namesForBusStops(delegateStops, preserveOrder: false)
		}
		
		if routeDataAvailable, let nextStop = appDelegate.busController.currentUserBus?.nextStop {
			busStopNames = filterAlreadyPassedBusStops(busStopNames, nextStop: nextStop.name)
		}
		
		let userData = appDelegate.userDataController.userData
		let recentSearches = userData.recentSearches
		
		for recentSearch in recentSearches {
			if let index = busStopNames.indexOf(recentSearch){ // if recentSearch entry is in busStopNames
				busStopNames.removeAtIndex(index) // remove from busStopNames
				recentSearchEntries.append(recentSearch) // add to recent searches
			}
		}
		
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = false
		tableView.tableHeaderView = searchController.searchBar
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.active && searchController.searchBar.text != "" {
			return filteredRecentSearchEntries.count + filteredBusStopNames.count
		}
		
		return recentSearchEntries.count + busStopNames.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("busStopCell", forIndexPath: indexPath)
		
		var stopNames = busStopNames
		var recentSearches = recentSearchEntries
		
		//If search bar is active, show filtered results
		if searchController.active && searchController.searchBar.text != "" {
			stopNames = filteredBusStopNames
			recentSearches = filteredRecentSearchEntries
		}
		
		
		if indexPath.row < recentSearches.count {
			//make recent search entry bold
			cell.textLabel?.attributedText = NSAttributedString(string: recentSearches[indexPath.row], attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(17)])
		} else {
			cell.textLabel?.text = stopNames[indexPath.row - recentSearches.count]
		}
		
		return cell
	}
	
	
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		var selectedStop = ""
		var stopNames = busStopNames
		var recentSearches = recentSearchEntries
		
		//If search bar is active, use filtered results
		if searchController.active && searchController.searchBar.text != "" {
			stopNames = filteredBusStopNames
			recentSearches = filteredRecentSearchEntries
		}
		
		if indexPath.row < recentSearches.count {
			selectedStop = recentSearches[indexPath.row]
		} else {
			selectedStop = stopNames[indexPath.row - recentSearches.count]
		}
		
		appDelegate.userDataController.addRecentSearch(selectedStop)
		
		searchController.active = false
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		for delegate in destinationDelegates {
			delegate.didSetDestination(selectedStop)
		}
		
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	func filterAlreadyPassedBusStops(stops: [String], nextStop: String) -> [String] {
		for (index, stop) in stops.enumerate() {
			if stop == nextStop {
				return Array(stops[(index + 1)..<stops.count])
			}
		}
		
		return stops
	}
	
	
	func filterBusStopsForSearchText(searchText: String){
		filteredBusStopNames = busStopNames.filter({ (stop) -> Bool in
			return stop.lowercaseString.containsString(searchText.lowercaseString) //case-insensitive
		})
		
		filteredRecentSearchEntries = recentSearchEntries.filter({ (stop) -> Bool in
			return stop.lowercaseString.containsString(searchText.lowercaseString) //case-insensitive
		})
		
		tableView.reloadData()
	}
}




extension DestinationSelectionTableViewController : UISearchResultsUpdating {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		//trim leading/trailing whitespace
		filterBusStopsForSearchText(searchController.searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
	}
}