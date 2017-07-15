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
	@IBOutlet weak var arrivalDateLabel: UILabel!
	@IBOutlet weak var alarmImageView: UIImageView! {
		didSet {
			alarmImageView.tintColor = UIColor.white
			alarmImageView.image = alarmImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	func dimSubViews() {
		nameLabel.layer.opacity = 0.5
		iconImageView.layer.opacity = 0.5
	}

	func brightenSubViews() {
		nameLabel.layer.opacity = 1
		iconImageView.layer.opacity = 1
	}

}
