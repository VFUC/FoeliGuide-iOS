//
//  DestinationSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 08/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

protocol DestinationSetDelegate {
	func didSetDestination(_ destination: String)
}


class DestinationSelectionTableViewController: UITableViewController {
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var busStopNames = [String]() {
		didSet {
			if !routeDataAvailable {
				busStopNames.sort( by: { $0 < $1 } )
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
			if let index = busStopNames.index(of: recentSearch){ // if recentSearch entry is in busStopNames
				busStopNames.remove(at: index) // remove from busStopNames
				recentSearchEntries.append(recentSearch) // add to recent searches
			}
		}
		
		searchController.searchResultsUpdater = self
		searchController.searchBar.placeholder = NSLocalizedString("Search bus stops", comment: "Destination search placeholder")
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = false
		tableView.tableHeaderView = searchController.searchBar
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.isActive && searchController.searchBar.text != "" {
			return filteredRecentSearchEntries.count + filteredBusStopNames.count
		}
		
		return recentSearchEntries.count + busStopNames.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "busStopCell", for: indexPath)
		
		var stopNames = busStopNames
		var recentSearches = recentSearchEntries
		
		//If search bar is active, show filtered results
		if searchController.isActive && searchController.searchBar.text != "" {
			stopNames = filteredBusStopNames
			recentSearches = filteredRecentSearchEntries
		}
		
		
		if indexPath.row < recentSearches.count {
			//make recent search entry bold
			cell.textLabel?.attributedText = NSAttributedString(string: recentSearches[indexPath.row], attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)])
		} else {
			cell.textLabel?.text = stopNames[indexPath.row - recentSearches.count]
		}
		
		return cell
	}
	
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var selectedStop = ""
		var stopNames = busStopNames
		var recentSearches = recentSearchEntries
		
		//If search bar is active, use filtered results
		if searchController.isActive && searchController.searchBar.text != "" {
			stopNames = filteredBusStopNames
			recentSearches = filteredRecentSearchEntries
		}
		
		if indexPath.row < recentSearches.count {
			selectedStop = recentSearches[indexPath.row]
		} else {
			selectedStop = stopNames[indexPath.row - recentSearches.count]
		}
		
		appDelegate.userDataController.addRecentSearch(selectedStop)
		
		searchController.isActive = false
		tableView.deselectRow(at: indexPath, animated: true)
		
		for delegate in destinationDelegates {
			delegate.didSetDestination(selectedStop)
		}
		
		self.navigationController?.popViewController(animated: true)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	func filterAlreadyPassedBusStops(_ stops: [String], nextStop: String) -> [String] {
		for (index, stop) in stops.enumerated() {
			if stop == nextStop {
				return Array(stops[(index + 1)..<stops.count])
			}
		}
		
		return stops
	}
	
	
	func filterBusStopsForSearchText(_ searchText: String){
		filteredBusStopNames = busStopNames.filter({ (stop) -> Bool in
			return stop.lowercased().contains(searchText.lowercased()) //case-insensitive
		})
		
		filteredRecentSearchEntries = recentSearchEntries.filter({ (stop) -> Bool in
			return stop.lowercased().contains(searchText.lowercased()) //case-insensitive
		})
		
		tableView.reloadData()
	}
}




extension DestinationSelectionTableViewController : UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		
		//trim leading/trailing whitespace
		filterBusStopsForSearchText(searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces))
	}
}
