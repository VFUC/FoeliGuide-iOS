//
//  BusSelectionCollectionViewCell.swift
//  FöliGuide
//
//  Created by Jonas on 08/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusSelectionCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var numberLabel: UILabel!
	
	
	func selectionAnimation() {
		numberLabel.layer.opacity = 0.18
		UIView.animateWithDuration(0.420) { () -> Void in
			self.numberLabel.layer.opacity = 1
		}
	}
	
	
}
