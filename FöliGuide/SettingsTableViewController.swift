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
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	@IBOutlet weak var dataRefreshRateSwitch: UISwitch!
	@IBOutlet weak var notifyOnceSwitch: UISwitch!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataRefreshRateSwitch.isOn = appDelegate.userDataController.userData.refreshDataLessFrequently
		notifyOnceSwitch.isOn = appDelegate.userDataController.userData.onlyNotifyOnce
	}
	
	override func viewWillAppear(_ animated: Bool) {
		UIApplication.shared.statusBarStyle = .default
	}
	
	
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func dataRefreshRateSwitchChanged(_ sender: UISwitch) {
		appDelegate.userDataController.userData.refreshDataLessFrequently = sender.isOn
	}
	
	@IBAction func notifyOnceSwitchChanged(_ sender: UISwitch) {
		appDelegate.userDataController.userData.onlyNotifyOnce = sender.isOn
	}
	
	
	
	@IBAction func creditsShowMorePressedAlamofire(_ sender: UIButton) {
		let sfc = SFSafariViewController(url: URL(string: "https://github.com/Alamofire/Alamofire")!)
		present(sfc, animated: true, completion: nil)
	}
	
	@IBAction func creditsShowMorePressedSwiftyJSON(_ sender: UIButton) {
		let sfc = SFSafariViewController(url: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!)
		present(sfc, animated: true, completion: nil)
	}
	
	@IBAction func creditsShowMorePressedPermissionScope(_ sender: UIButton) {
		let sfc = SFSafariViewController(url: URL(string: "https://github.com/nickoneill/PermissionScope")!)
		present(sfc, animated: true, completion: nil)
	}
	
}
