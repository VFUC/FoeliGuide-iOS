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
	
	@IBOutlet weak var selectBusImageButton: UIButton! {
		didSet {
			selectBusImageButton.accessibilityLabel = NSLocalizedString("Select your bus", comment: "")
		}
	}
	
	@IBOutlet weak var selectBusLabelButton: UIButton! {
		didSet {
			selectBusLabelButton.accessibilityLabel = NSLocalizedString("Select your bus", comment: "")
		}
	}
	
	@IBOutlet weak var settingsBarButton: UIBarButtonItem! {
		didSet {
			settingsBarButton.accessibilityLabel = NSLocalizedString("Settings", comment: "")
		}
	}
	
	@IBOutlet weak var emptyBarButton: UIBarButtonItem! { //Sole purpose is to keep nav bar image centered, no function
		didSet {
			emptyBarButton.isAccessibilityElement = false
		}
	}
	
	@IBOutlet weak var networkErrorStackView: UIStackView!
	
	var didLoadBusStops = false {
		didSet {
			if didLoadBusStops && didLoadBusses {
				setLoadingFinishedState()
			}
		}
	}
	var didLoadBusses = false {
		didSet {
			if didLoadBusStops && didLoadBusses {
				setLoadingFinishedState()
			}
		}
	}
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		appDelegate.networkEventHandlers.append(self)
		
		if appDelegate.busStops == nil {
			setLoadingStartedState()
		}
		
		networkErrorStackView.hidden = true
		
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
	
	
	func setLoadingStartedState(){
		activityIndicator.startAnimating()
		selectBusLabelButton.hidden = true
		selectBusImageButton.hidden = true
		networkErrorStackView.hidden = true
	}
	
	func setLoadingFinishedState(){
		activityIndicator.stopAnimating()
		selectBusLabelButton.hidden = false
		selectBusImageButton.hidden = false
		networkErrorStackView.hidden = true
	}
	
	func setLoadingFailedState(){
		activityIndicator.stopAnimating()
		selectBusImageButton.hidden = true
		selectBusLabelButton.hidden = true
		networkErrorStackView.hidden = false
	}
	
	
	
	
	@IBAction func tryNetworkRequestAgainTapped(sender: UIButton) {
		setLoadingStartedState()
		appDelegate.initialDataLoading()
	}
	
	

}

extension MainViewController : NetworkEventHandler {
	func handleEvent(event: NetworkEvent) {
		switch event {
		case .BusStopLoadingStarted:
			setLoadingStartedState()
		case .BusStopLoadingFinished:
			didLoadBusStops = true
		case .BusLoadingFinished:
			didLoadBusses = true
			
		case .LoadingFailed:
			setLoadingFailedState()
		default:
			break
		}
	}
}
