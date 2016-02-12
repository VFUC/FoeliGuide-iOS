//
//  DestinationSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 08/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class DestinationSelectionTableViewController: UITableViewController {
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	var busStopNames = [String]() {
		didSet {
			busStopNames.sortInPlace( { $0 < $1 } )
		}
	}
	var recentSearchEntries = [String]()
	
	var filteredRecentSearchEntries = [String]()
	var filteredBusStopNames = [String]()
	
	var nextStopVC : NextBusStopViewController?
	
	
	let searchController = UISearchController(searchResultsController: nil)
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let delegateStops = appDelegate.busStopNames {
			busStopNames = delegateStops
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
		nextStopVC?.destinationStop = selectedStop
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	
	/*
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	if editingStyle == .Delete {
	// Delete the row from the data source
	tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	} else if editingStyle == .Insert {
	// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
	}
	*/
	
	/*
	// Override to support rearranging the table view.
	override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
	
	}
	*/
	
	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	// Return false if you do not want the item to be re-orderable.
	return true
	}
	*/
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	
	
	
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