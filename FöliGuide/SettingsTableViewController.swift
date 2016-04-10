//
//  SettingsTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 10/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController {
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	@IBOutlet weak var dataRefreshRateSwitch: UISwitch!
	@IBOutlet weak var notifyOnceSwitch: UISwitch!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataRefreshRateSwitch.on = appDelegate.userDataController.userData.refreshDataLessFrequently
		notifyOnceSwitch.on = appDelegate.userDataController.userData.onlyNotifyOnce
	}
	
	
	
	@IBAction func doneButtonPressed(sender: UIButton) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func dataRefreshRateSwitchChanged(sender: UISwitch) {
		appDelegate.userDataController.userData.refreshDataLessFrequently = sender.on
	}
	
	@IBAction func notifyOnceSwitchChanged(sender: UISwitch) {
		appDelegate.userDataController.userData.onlyNotifyOnce = sender.on
	}
	
	
	
	@IBAction func creditsShowMorePressedAlamofire(sender: UIButton) {
		let sfc = SFSafariViewController(URL: NSURL(string: "https://github.com/Alamofire/Alamofire")!)
		presentViewController(sfc, animated: true, completion: nil)
	}
	
	@IBAction func creditsShowMorePressedSwiftyJSON(sender: UIButton) {
		let sfc = SFSafariViewController(URL: NSURL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!)
		presentViewController(sfc, animated: true, completion: nil)
	}
	
	@IBAction func creditsShowMorePressedPermissionScope(sender: UIButton) {
		let sfc = SFSafariViewController(URL: NSURL(string: "https://github.com/nickoneill/PermissionScope")!)
		presentViewController(sfc, animated: true, completion: nil)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	// MARK: - Table view data source
	/*
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	// #warning Incomplete implementation, return the number of sections
	return 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	// #warning Incomplete implementation, return the number of rows
	return 0
	}*/
	
	/*
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
	
	// Configure the cell...
	
	return cell
	}
	*/
	
	/*
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	// Return false if you do not want the specified item to be editable.
	return true
	}
	*/
	
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
	
}
