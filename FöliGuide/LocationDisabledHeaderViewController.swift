//
//  LocationDisabledHeaderViewController.swift
//  FöliGuide
//
//  Created by Jonas on 14/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import PermissionScope

class LocationDisabledHeaderViewController: UIViewController {

	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	let permissionScope = PermissionScope()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		permissionScope.headerLabel.text = NSLocalizedString("Location Access", comment: "Location access header")
		permissionScope.bodyLabel.text = NSLocalizedString("Select your bus quicker and easier", comment: "Select your bus quicker and easier")
		let message = NSLocalizedString("Your location is used to locate the bus closest to you.", comment: "Your location is used to locate the bus closest to you.")
		permissionScope.addPermission(LocationWhileInUsePermission(), message: message)
    }

	@IBAction func didTapView(sender: AnyObject) {
		permissionScope.show({ finished, results in
			self.appDelegate.locationController.authorized = true
			self.appDelegate.locationController.requestLocationUpdate()
			
			}, cancelled: { (results) -> Void in
				self.appDelegate.locationController.authorized = false
		})
	}
}
