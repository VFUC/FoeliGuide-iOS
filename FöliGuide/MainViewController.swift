//
//  MainViewController.swift
//  FöliGuide
//
//  Created by Jonas on 25/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	@IBOutlet weak var debugLabel: UILabel!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//
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
