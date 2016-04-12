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
	
	override func viewWillAppear(animated: Bool) {
		UIApplication.sharedApplication().statusBarStyle = .Default
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
	
}
