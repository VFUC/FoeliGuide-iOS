//
//  BusDetailViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusDetailViewController: UIViewController {

	@IBOutlet weak var containerView: UIView!
	
	@IBOutlet weak var busNumberLabel: UILabel!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		busNumberLabel.text = appDelegate.busController.currentUserBus?.name ?? "?"
		
		appDelegate.busController.getBusRoute(forBus: appDelegate.busController.currentUserBus!) { (busStops) -> () in
			
			guard busStops != nil else {
				self.loadSubViewController(withIdentifier: "NextStopSubViewController")
				return
			}
			
			self.appDelegate.busController.currentUserBus?.route = busStops
			self.loadSubViewController(withIdentifier: "BusRouteSubViewController")
		}
		
    }
	
	func loadSubViewController(withIdentifier identifier: String){
		let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		let vc = storyboard.instantiateViewControllerWithIdentifier(identifier)
		
		
		addChildViewController(vc)
		vc.view.frame = CGRect(x: 0,y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
		containerView.addSubview(vc.view)
		vc.didMoveToParentViewController(self)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
