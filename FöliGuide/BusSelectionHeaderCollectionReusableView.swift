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
		headerLabel.text = "Loading nearby busses"
	}
	
	func showNormalState(){
		loadingIndicator.stopAnimating()
		headerLabel.text = "Select your bus"
	}
	
	
}
