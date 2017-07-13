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
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		appDelegate.networkEventHandlers.append(self)
		
		if appDelegate.busStops == nil {
			setLoadingStartedState()
		}
		
		networkErrorStackView.isHidden = true
		
		let topImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
		topImageView.image = UIImage(named: "appicon-transparent-landscape-400")
		topImageView.contentMode = .scaleAspectFit
		
		self.navigationItem.titleView = topImageView
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		UIApplication.shared.statusBarStyle = .lightContent
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func setLoadingStartedState(){
		activityIndicator.startAnimating()
		selectBusLabelButton.isHidden = true
		selectBusImageButton.isHidden = true
		networkErrorStackView.isHidden = true
	}
	
	func setLoadingFinishedState(){
		activityIndicator.stopAnimating()
		selectBusLabelButton.isHidden = false
		selectBusImageButton.isHidden = false
		networkErrorStackView.isHidden = true
	}
	
	func setLoadingFailedState(){
		activityIndicator.stopAnimating()
		selectBusImageButton.isHidden = true
		selectBusLabelButton.isHidden = true
		networkErrorStackView.isHidden = false
	}
	
	
	
	
	@IBAction func tryNetworkRequestAgainTapped(_ sender: UIButton) {
		setLoadingStartedState()
		appDelegate.initialDataLoading()
	}
	
	

}

extension MainViewController : NetworkEventHandler {
	func handleEvent(_ event: NetworkEvent) {
		switch event {
		case .busStopLoadingStarted:
			setLoadingStartedState()
		case .busStopLoadingFinished:
			didLoadBusStops = true
		case .busLoadingFinished:
			didLoadBusses = true
			
		case .loadingFailed:
			setLoadingFailedState()
		default:
			break
		}
	}
}
