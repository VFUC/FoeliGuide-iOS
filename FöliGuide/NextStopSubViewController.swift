//
//  NextStopSubViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

class NextStopSubViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as? AppDelegate


    @IBOutlet weak var nextStationNameLabel: UILabel!
    @IBOutlet weak var afterThatStationNameLabel: UILabel!
    @IBOutlet weak var selectedBusStationNameLabel: UILabel!

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var selectedBusStationStackView: UIStackView!


    override func viewDidLoad() {
        super.viewDidLoad()

        nextStationNameLabel.text = appDelegate?.busController.currentUserBus?.nextStop.name ?? ""
        afterThatStationNameLabel.text = appDelegate?.busController.currentUserBus?.afterThatStop?.name ?? ""
        appDelegate?.busDataUpdateDelegates.append(self)

        //remove initially
        mainStackView.removeArrangedSubview(selectedBusStationStackView)
        selectedBusStationStackView.isHidden = true


        if let detailVC = parent as? BusDetailViewController {
            detailVC.delegates.append(self)
        }
    }


    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil, let appDelegate = appDelegate {
			appDelegate.busDataUpdateDelegates = appDelegate.busDataUpdateDelegates.filter({ !($0 is NextBusStopViewController) })
        }
    }
}

// Data has been updated, check if notification is necessary
extension NextStopSubViewController: BusUpdateDelegate {
    func didUpdateBusData() {

        guard let bus = appDelegate?.busController.currentUserBus else {
            return
        }

        guard let detailVC = self.parent as? BusDetailViewController else {
            print("[NextStopVC] My parent VC is not a busDetailVC (which I expected)")
            return
        }


        guard detailVC.busNumberLabel.text != bus.name || nextStationNameLabel.text != bus.nextStop.name else {
            //Data did not change
            return
        }


        nextStationNameLabel.text = bus.nextStop.name
        afterThatStationNameLabel.text = bus.afterThatStop?.name ?? "--"

        afterThatStationNameLabel.isHidden = (nextStationNameLabel.text == afterThatStationNameLabel.text) //Hide if both labels are equal

    }
}

extension NextStopSubViewController: BusDetailViewControllerDelegate {

    func didSetAlarm(_ alarmSet: Bool) {
        if alarmSet {
            mainStackView.addArrangedSubview(selectedBusStationStackView)
            selectedBusStationStackView.isHidden = false
        } else {
            mainStackView.removeArrangedSubview(selectedBusStationStackView)
            selectedBusStationStackView.isHidden = true
        }
    }

    func didSelectDestination(_ destination: String) {
        selectedBusStationNameLabel.text = destination
    }
}
