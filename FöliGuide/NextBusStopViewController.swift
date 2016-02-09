//
//  NextBusStopViewController.swift
//  FöliGuide
//
//  Created by Jonas on 01/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class NextBusStopViewController: UIViewController {

	@IBOutlet weak var busNumberLabel: UILabel!
	@IBOutlet weak var nextStationNameLabel: UILabel! {
		didSet {
			if nextStationNameLabel.text == destinationStop {
				print("NEXT STOP IS DESTINATION")
			} else {
				print("NEXT STOP IS NOT DESTINATION")
			}
		}
	}
	
	@IBOutlet weak var destinationLabel: UILabel!
	@IBOutlet weak var destinationHeader: UILabel!
	@IBOutlet weak var destinationStackView: UIStackView!
	@IBOutlet weak var mainStackView: UIStackView!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	var destinationVisible = false {
		didSet {
			if destinationVisible {
				mainStackView.addArrangedSubview(destinationStackView)
			} else {
				mainStackView.removeArrangedSubview(destinationStackView)
			}
		}
	}
	
	var destinationStop : String? {
		didSet {
			destinationVisible = !(destinationStop == nil)
			destinationLabel.text = destinationStop
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		destinationStop = nil
		busNumberLabel.text = ""
		nextStationNameLabel.text = ""
		appDelegate.nextBusStopVC = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if let vc = segue.destinationViewController as? DestinationSelectionTableViewController {
			vc.nextStopVC = self
		}
	}
	
}
