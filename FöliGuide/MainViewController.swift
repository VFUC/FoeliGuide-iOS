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
	
	@IBOutlet weak var selectBusImageButton: UIButton!
	@IBOutlet weak var selectBusLabelButton: UIButton!
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		appDelegate.networkEventHandlers.append(self)
		
		if appDelegate.busStops == nil {
			setBusStopLoadingStartedState()
		}
		
		let topImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
		topImageView.image = UIImage(named: "appicon-transparent-landscape-400")
		topImageView.contentMode = .ScaleAspectFit
		
		self.navigationItem.titleView = topImageView
		
	}
	
	override func viewWillAppear(animated: Bool) {
		UIApplication.sharedApplication().statusBarStyle = .LightContent
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func setBusStopLoadingStartedState(){
		activityIndicator.startAnimating()
		selectBusLabelButton.hidden = true
		selectBusImageButton.hidden = true
	}
	
	func setBusStopLoadingFinishedState(){
		activityIndicator.stopAnimating()
		selectBusLabelButton.hidden = false
		selectBusImageButton.hidden = false
	}

}

extension MainViewController : NetworkEventHandler {
	func handleEvent(event: NetworkEvent) {
		switch event {
		case .BusStopLoadingStarted:
			setBusStopLoadingStartedState()
		case .BusStopLoadingFinished:
			setBusStopLoadingFinishedState()
		default:
			break
		}
	}
}
