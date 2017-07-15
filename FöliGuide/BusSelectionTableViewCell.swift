//
//  BusSelectionTableViewCell.swift
//  FöliGuide
//
//  Created by Jonas on 19/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class BusSelectionTableViewCell: UITableViewCell {

	@IBOutlet weak var busNumberLabel: UILabel!
	@IBOutlet weak var finalStopLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
