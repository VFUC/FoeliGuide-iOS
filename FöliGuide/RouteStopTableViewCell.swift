//
//  RouteStopTableViewCell.swift
//  FöliGuide
//
//  Created by Jonas on 21/03/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class RouteStopTableViewCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func dimSubViews(){
		nameLabel.layer.opacity = 0.5
		iconImageView.layer.opacity = 0.5
	}
	
	func brightenSubViews(){
		nameLabel.layer.opacity = 1
		iconImageView.layer.opacity = 1
	}

}
