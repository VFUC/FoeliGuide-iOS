//
//  MainViewController.swift
//  FöliGuide
//
//  Created by Jonas on 25/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var nextBusStopButton: UIButton!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		activityIndicator.startAnimating()
		nextBusStopButton.hidden = true
		
		let topImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
		topImageView.image = UIImage(named: "appicon-transparent-landscape-400")
		topImageView.contentMode = .ScaleAspectFit
		
		self.navigationItem.titleView = topImageView
		
	}
	
	override func viewDidAppear(animated: Bool) {
		appDelegate.mainVC = self
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
