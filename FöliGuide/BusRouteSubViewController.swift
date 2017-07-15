//
//  BusRouteSubViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class BusRouteSubViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: Outlets
    @IBOutlet weak var busStopsTableView: UITableView! {
        didSet {
            busStopsTableView.delegate = self
            busStopsTableView.dataSource = self
        }
    }


    // MARK: Data
    var displayStops = [BusStop]() {
        didSet { //remove duplicate stop names in route
            if hasDuplicateStops(displayStops) { //Will be recursively called until no more duplicates
                displayStops = removeFirstDuplicateStop(displayStops)
            }
        }
    }
    var destinationStop: String?
    var lastReceivedNextBusStopName: String?



    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate?.busDataUpdateDelegates.append(self)

        if let detailVC = parent as? BusDetailViewController {
            detailVC.delegates.append(self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        scrollToNextBusStop(animated: true)
    }


    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil, let appDelegate = appDelegate {
            for (index, delegate) in appDelegate.busDataUpdateDelegates.enumerated() {
                if let _ = delegate as? BusRouteSubViewController {
                    appDelegate.busDataUpdateDelegates.remove(at: index)
                }
            }
        }
    }



    func hasDuplicateStops(_ stops: [BusStop]) -> Bool {
        for (index, stop) in stops.enumerated() {
            if index - 1  >= 0 {
                if stops[index - 1].name == stop.name {
                    return true
                }
            }
        }

        return false
    }

    func removeFirstDuplicateStop(_ stops: [BusStop]) -> [BusStop] {
        var stopCopy = stops

        for (index, stop) in stopCopy.enumerated()
            where index > 0 && stopCopy[index - 1].name == stop.name {
                stopCopy.remove(at: index)
                return stopCopy
        }

        return stopCopy
    }


    func scrollToNextBusStop(animated: Bool) {

        var nextStopIndex: Int?
        guard let stops = appDelegate?.busController.currentUserBus?.route else {
            return
        }

        displayStops = stops

        for (index, stop) in displayStops.enumerated() where stop.name == appDelegate?.busController.currentUserBus?.nextStop.name {
            nextStopIndex = index
            break
        }

        guard let index = nextStopIndex else {
            return
        }

        self.busStopsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: animated)

    }
}


extension BusRouteSubViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var nextStopIndex: Int?

        guard let stops = appDelegate?.busController.currentUserBus?.route else {
            return tableView.dequeueReusableCell(withIdentifier: "defaultBusStopCell", for: indexPath)
        }

        displayStops = stops

        guard indexPath.row < displayStops.count else {
            return tableView.dequeueReusableCell(withIdentifier: "defaultBusStopCell", for: indexPath)
        }

        let stop = displayStops[indexPath.row]

        for (index, stop) in displayStops.enumerated()
            where stop.name == appDelegate?.busController.currentUserBus?.nextStop.name {
                nextStopIndex = index
                break
        }

        var reuseIdentifier = "defaultBusStopCell"

        switch indexPath.row {
        case 0:
            reuseIdentifier = "firstBusStopCell"
        case 1..<displayStops.count - 1:
            reuseIdentifier = "middleBusStopCell"
        case displayStops.count - 1:
            reuseIdentifier = "lastBusStopCell"
        default:
            reuseIdentifier = "defaultBusStopCell"
        }

        if indexPath.row == nextStopIndex {
            reuseIdentifier = "nextStopCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        guard let stopCell = cell as? RouteStopTableViewCell else {
            return cell
        }

        stopCell.nameLabel.text = stop.name
        stopCell.alarmImageView.isHidden = !(stop.name == destinationStop)

        //Put cell on half opacity if the bus stop has already been passed
        if let nextStopIndex = nextStopIndex, indexPath.row < nextStopIndex {
            stopCell.dimSubViews()
            stopCell.isUserInteractionEnabled = false
            stopCell.accessibilityLabel = stop.name + ", " + "This stop has already been passed".localized
        } else {
            stopCell.brightenSubViews()
            stopCell.isUserInteractionEnabled = true
            stopCell.selectionStyle = .none


            if let nextStopIndex = nextStopIndex, indexPath.row > nextStopIndex {
                stopCell.accessibilityLabel = stop.name + ", " + String.localizedStringWithFormat("%d stops away".localized, indexPath.row + 1 - nextStopIndex)
            }

        }

        if let nextStopIndex = nextStopIndex, indexPath.row == nextStopIndex {
            stopCell.isUserInteractionEnabled = false
        }

        //Change icons if next stop cell is first or last
        if indexPath.row == nextStopIndex { // cell is nextStopCell

            if let nextStopArrivalDate = appDelegate?.busController.currentUserBus?.nextStop.expectedArrival {
                let intervalInSeconds = nextStopArrivalDate.timeIntervalSinceNow
                let minutes = Int(intervalInSeconds / 60)

                if minutes <= 0 {
                    stopCell.arrivalDateLabel.text  = "now".localized
                    stopCell.arrivalDateLabel.accessibilityLabel = "arriving".localized + " " + "now".localized
                } else {
                    let inMin = NSLocalizedString("in %d min", comment: "Arriving at bus station in n minutes")
                    stopCell.arrivalDateLabel.text = String.localizedStringWithFormat(inMin, minutes)
                    stopCell.arrivalDateLabel.accessibilityLabel = "arriving".localized + " " + String.localizedStringWithFormat(inMin, minutes)
                }

            } else {
                stopCell.arrivalDateLabel.text = ""
            }

            if indexPath.row == 0 {
                stopCell.iconImageView.image = UIImage(named: "route-icon-top")
            }
            if indexPath.row == (displayStops.count - 1) {
                stopCell.iconImageView.image = UIImage(named: "route-icon-next-bottom")
            }
        }


        return stopCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stops = appDelegate?.busController.currentUserBus?.route else {
            return 0
        }

        displayStops = stops
        return displayStops.count
    }

}

extension BusRouteSubViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < displayStops.count else {
            return
        }


        // Already passed bus stops are not selectable
        var nextStopIndex: Int?
        for (index, stop) in displayStops.enumerated() {
            if stop.name == appDelegate?.busController.currentUserBus?.nextStop.name {
                nextStopIndex = index
                break
            }
        }
        guard indexPath.row > nextStopIndex else {
            return
        }

    }

}


extension BusRouteSubViewController: BusUpdateDelegate {
    func didUpdateBusData() {
        busStopsTableView.reloadData()

        //Check if next stop did Change
        if let newNextBusStop = appDelegate?.busController.currentUserBus?.nextStop.name {
            if newNextBusStop != lastReceivedNextBusStopName { //didChange
                scrollToNextBusStop(animated: true)
                lastReceivedNextBusStopName = newNextBusStop
            }
        }
    }
}


extension BusRouteSubViewController: BusDetailViewControllerDelegate {
    func didTapHead() {
        scrollToNextBusStop(animated: true)
    }

    func didSetAlarm(_ alarmSet: Bool) {
        if alarmSet == false {

            if let previousStop = destinationStop { //previously set a stop
                //remove alarm icon
                for (index, stop) in self.displayStops.enumerated() where stop.name == previousStop {
                    if let cell = self.busStopsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RouteStopTableViewCell {
                        cell.alarmImageView.isHidden = true
                    }
                }
            }
            destinationStop = nil
        }
    }

    func didSelectDestination(_ destination: String) {

        if let previousStop = destinationStop { //previously set a stop
            //remove alarm icon
            for (index, stop) in self.displayStops.enumerated() where stop.name == previousStop {
                if let cell = self.busStopsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RouteStopTableViewCell {
                    cell.alarmImageView.isHidden = true
                }
            }
        }

        //set alarm icon on selected alarm
        for (index, stop) in self.displayStops.enumerated() where stop.name == destination {
            if let cell = self.busStopsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RouteStopTableViewCell {
                cell.alarmImageView.isHidden = false
            }
        }

        destinationStop = destination
    }
}
