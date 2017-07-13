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
	@IBOutlet weak var finalStopLabel: UILabel!
	
	@IBOutlet var allLabels: [UILabel]!
	
	
	// visual feedback to look like a button when cell is tapped
	func selectionAnimation() {
		
		for label in allLabels {
			label.layer.opacity = 0.18
		}
		
		UIView.animate(withDuration: 0.420, animations: { () -> Void in
			for label in self.allLabels {
				label.layer.opacity = 1
			}
		}) 
	}
	
	
}
