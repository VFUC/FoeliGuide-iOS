//
//  BusDetailViewController.swift
//  FöliGuide
//
//  Created by Jonas on 06/04/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

@objc protocol BusDetailViewControllerDelegate {
    @objc optional func didTapHead()
    @objc optional func didSetAlarm(_ alarmSet: Bool)
    @objc optional func didSelectDestination(_ destination: String)
}


class BusDetailViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingSpinner: ALThreeCircleSpinner!
    @IBOutlet weak var alarmBarButton: UIBarButtonItem! {
        didSet {
            alarmBarButton.accessibilityLabel = "Set an alarm".localized
        }
    }

    @IBOutlet weak var volumeButton: UIButton! {
        didSet {
            volumeButton.imageView?.contentMode = .scaleAspectFit
        }
    }

    @IBOutlet weak var busNumberLabel: UILabel!

    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var subViewController: UIViewController?
    var delegates = [BusDetailViewControllerDelegate]()

    var alarmSet = false {
        didSet {
            appDelegate?.alarmIsSet = alarmSet

            alarmBarButton.image = alarmSet ? UIImage(named: Constants.Assets.Images.AlarmBarButton.Filled): UIImage(named: Constants.Assets.Images.AlarmBarButton.Outline)

            for delegate in delegates {
                delegate.didSetAlarm?(alarmSet)
            }
        }
    }

    var destinationStop: String? {
        didSet {
            alarmSet = !(destinationStop == nil)

            if let stop = destinationStop {
                didNotifyUserAboutUpcomingDestination = false
                for delegate in delegates {
                    delegate.didSelectDestination?(stop)
                }
            }
        }
    }

    var volumeEnabled = false {
        didSet {
            volumeButton.accessibilityLabel = volumeEnabled ? "Turn off announcements".localized: "Turn on announcements".localized

            if volumeEnabled {
                volumeButton.setImage(UIImage(named: "ios-volume-high"), for: UIControlState())

                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                    self.announceNextTwoBusStops()
                })

            } else {
                SpeechController.stopSpeaking()
                volumeButton.setImage(UIImage(named: "ios-volume-low"), for: UIControlState())
            }
        }
    }

    var didNotifyUserAboutUpcomingDestination = false //Used when user wants to be notified only once

    var nextStop: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate?.busDataUpdateDelegates.append(self)

        loadingSpinner.startAnimating()
        busNumberLabel.text = appDelegate?.busController.currentUserBus?.name ?? "?"

        volumeEnabled = false

        delegates = [BusDetailViewControllerDelegate]() //Reset delegates

        guard let appDelegate = appDelegate else { return }

        appDelegate.networkEventHandlers.append(self)
        appDelegate.applicationEventHandlers.append(self)

        guard let currentBus = appDelegate.busController.currentUserBus else { return }

        appDelegate.busController.getBusRoute(forBus: currentBus) { (busStops) -> Void in

            self.loadingSpinner.stopAnimating()


            guard busStops != nil else {
                self.loadSubViewController(withIdentifier: "NextStopSubViewController")
                return
            }

            var route = busStops!

            if let currentBus = self.appDelegate?.busController.currentUserBus {
                //Check if route is going in wrong direction, needs to be reversed

                if let afterThatStopName = currentBus.afterThatStop?.name {
                    let nextStopName = currentBus.nextStop.name

                    //get index of both upcoming stop names on route
                    var nextStopIndex: Int?
                    var afterThatStopIndex: Int?

                    for (index, stop) in busStops!.enumerated() {
                        if stop.name == nextStopName {
                            nextStopIndex = index
                        }

                        if stop.name == afterThatStopName {
                            afterThatStopIndex = index
                        }
                    }

                    //Flip if direction is incorrect
                    if let n = nextStopIndex, let a = afterThatStopIndex, a < n {
                        route = route.reversed()
                    }
                }
            }

            self.appDelegate?.busController.currentUserBus?.route = route
            self.loadSubViewController(withIdentifier: "BusRouteSubViewController")
        }

    }


    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController && subViewController != nil { //View is being dismissed -> moving back to previous screen
            subViewController!.willMove(toParentViewController: nil)
            subViewController!.view.removeFromSuperview()
            subViewController!.removeFromParentViewController()

            volumeEnabled = false
        }
    }


    func loadSubViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        subViewController = vc

        addChildViewController(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        containerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }


    func announceNextTwoBusStops() {
        if let nextStation = appDelegate?.busController.currentUserBus?.nextStop.name {
            SpeechController.announceNextBusStop(nextStation)
        }

        if let afterThatStation = appDelegate?.busController.currentUserBus?.afterThatStop?.name {
            SpeechController.announceFollowingBusStop(afterThatStation)
        }
    }

    func showNetworkErrorAlert() {
        let vc = UIAlertController(title: "Network Error".localized, message: "Please check your internet connection".localized, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (_) in
            vc.removeFromParentViewController()
        }))
        present(vc, animated: true, completion: nil)
    }

    func showAppClosedWithActiveAlarmAlert() {
        let vc = UIAlertController(title: "Alarm will not ring when app is closed".localized, message: "In order to accurately determine where your bus is, the app loads data from the Föli servers several times a minute. If you close the app, it is not possible to check frequently enough anymore.".localized, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (_) in
            vc.removeFromParentViewController()
        }))
        present(vc, animated: true, completion: nil)
    }


    @IBAction func didTapHead(_ sender: UITapGestureRecognizer) {
        for delegate in delegates {
            delegate.didTapHead?()
        }
    }

    @IBAction func didTapAlarmButton(_ sender: UIBarButtonItem) {
        if alarmSet {

            let title = NSLocalizedString("Remove alarm?", comment: "Asking the user if he's sure to remove the alarm")
            let message = String.localizedStringWithFormat(NSLocalizedString("Do you want to remove the alarm for %@?", comment: "Name the bus station the user is about to delete the alarm for"), (destinationStop ?? "--"))

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove button label"), style: .destructive, handler: { _ -> Void in
                self.destinationStop = nil
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button label"), style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)

        } else {
            self.performSegue(withIdentifier: "showDestinationSelectionVC", sender: nil)
        }
    }

    @IBAction func didTapVolumeButton(_ sender: UIButton) {
        volumeEnabled = !volumeEnabled
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DestinationSelectionTableViewController {
            vc.destinationDelegates.append(self)
        }
    }

}


extension BusDetailViewController: DestinationSetDelegate {
    func didSetDestination(_ destination: String) {
        destinationStop = destination
    }
}


extension BusDetailViewController: BusUpdateDelegate {
    func didUpdateBusData() {
        if let newNextStop = appDelegate?.busController.currentUserBus?.nextStop.name {
            if nextStop != newNextStop { //Next stop has changed
                nextStop = newNextStop

                if volumeEnabled {
                    announceNextTwoBusStops()
                }

                if newNextStop == destinationStop {

                    if appDelegate?.userDataController.userData.onlyNotifyOnce == false ||  ((appDelegate?.userDataController.userData.onlyNotifyOnce == true) && !didNotifyUserAboutUpcomingDestination ) {
                        NotificationController.showNextBusStationNotification(stopName: newNextStop, viewController: self)
                        didNotifyUserAboutUpcomingDestination = true
                    }

                    destinationStop = nil
                }

                if let afterThatStop = appDelegate?.busController.currentUserBus?.afterThatStop?.name, afterThatStop == destinationStop {

                    if appDelegate?.userDataController.userData.onlyNotifyOnce == false ||  ((appDelegate?.userDataController.userData.onlyNotifyOnce == true) && !didNotifyUserAboutUpcomingDestination ) {
                        NotificationController.showAfterThatBusStationNotification(stopName: afterThatStop, viewController: self)
                        didNotifyUserAboutUpcomingDestination = true
                    }
                }

            }//next stop has changed
        }


    }
}

extension BusDetailViewController: ApplicationEventHandler {
    func handleEvent(_ event: ApplicationEvent) {
        if event == .closedAppWithActiveAlarm {
            showAppClosedWithActiveAlarmAlert()
        }
    }
}

extension BusDetailViewController: NetworkEventHandler {
    func handleEvent(_ event: NetworkEvent) {
        switch event {
        case .loadingFailed:
            showNetworkErrorAlert()
        default:
            break
        }
    }
}
