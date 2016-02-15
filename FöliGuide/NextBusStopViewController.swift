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
	@IBOutlet weak var nextStationNameLabel: UILabel!
	@IBOutlet weak var afterThatStationNameLabel: UILabel!
	@IBOutlet weak var finalStationName: UILabel!
	@IBOutlet weak var selectedBusStationNameLabel: UILabel!
	@IBOutlet weak var selectedBusStationStackView: UIStackView!
	@IBOutlet weak var mainStackView: UIStackView!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	var destinationVisible = false {
		didSet {
			if destinationVisible {
				mainStackView.addArrangedSubview(selectedBusStationStackView)
			} else {
				mainStackView.removeArrangedSubview(selectedBusStationStackView)
			}
		}
	}
	
	var destinationStop : String? {
		didSet {
			destinationVisible = !(destinationStop == nil)
			selectedBusStationNameLabel.text = destinationStop
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		destinationStop = nil
		busNumberLabel.text = ""
		nextStationNameLabel.text = ""
		afterThatStationNameLabel.text = ""
		appDelegate.nextBusStopVC = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	// Data has been updated, check if notification is necessary
	func didUpdateData(){
		if nextStationNameLabel.text == destinationStop {
			NotificationController.showNextBusStationNotification(stopName: nextStationNameLabel.text!, viewController: self)
		}
	
		if afterThatStationNameLabel.text == destinationStop {
			NotificationController.showAfterThatBusStationNotification(stopName: nextStationNameLabel.text!, viewController: self)
		}
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
