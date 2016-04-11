//
//  BusSelectionHeaderCollectionReusableView.swift
//  FöliGuide
//
//  Created by Jonas on 17/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusSelectionHeaderCollectionReusableView: UICollectionReusableView {

	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	
	
	func showLoadingLocationState(){
		loadingIndicator.startAnimating()
		headerLabel.text = NSLocalizedString("Loading nearby busses", comment: "used on loading indicator")
	}
	
	func showNormalState(){
		loadingIndicator.stopAnimating()
		headerLabel.text = NSLocalizedString("Select your bus", comment: "user prompt")
	}
	
	
}
