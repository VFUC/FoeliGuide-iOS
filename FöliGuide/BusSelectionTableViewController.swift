//
//  BusSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 19/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "BusCell"
private let cellReuseIdentifierWithDistance = "BusCellWithDistance"

class BusSelectionTableViewController: UITableViewController {

    var busses = [Bus]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak var headerContainerView: UIView!
    var headerVC: UIViewController?



    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate?.applicationEventHandlers.append(self)
        appDelegate?.startBusDataLoop()

        self.navigationItem.title = NSLocalizedString("Select your bus", comment: "Select your bus header")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Back Button"), style: .plain, target: nil, action: nil)

        guard let appDelegate = appDelegate else { return }

        if appDelegate.locationController.authorized {

            //show loading indicator until user data loaded
            if !appDelegate.didGetUserLocationOnce {
                loadHeaderViewController(withIdentifier: "LocationLoadingHeaderViewController")
            } else {
                tableView.tableHeaderView = nil
            }

        } else {
            loadHeaderViewController(withIdentifier: "LocationDisabledHeaderView")
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController, let appDelegate = appDelegate { //View is being dismissed -> moving back to main menu
            appDelegate.stopBusDataLoop()
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }



    func loadHeaderViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)

        headerVC = vc

        addChildViewController(vc)
        vc.view.frame = CGRect(x: 0, y: 0,
                               width: self.headerContainerView.frame.size.width,
                               height: self.headerContainerView.frame.size.height)
        headerContainerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }


    func loadData() {
        guard let appDelegate = appDelegate else { return }
        if let currentBusData = appDelegate.busController.currentBusData {
            busses = currentBusData
        }

        busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)

        tableView.reloadData()
    }


    func didUpdateUserLocation() {
        print("[BusSelectionTVC] Did receive user location update")
        if let vc = headerVC {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            tableView.tableHeaderView = nil
            headerVC = nil
        }
        guard let appDelegate = appDelegate else { return }
        busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)
        tableView?.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busses.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if appDelegate?.locationController.authorized == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifierWithDistance, for: indexPath)

            if let busStopCell = cell as? BusSelectionTableViewCell {
                busStopCell.busNumberLabel.text = busses[indexPath.row].name
                busStopCell.busNumberLabel.accessibilityLabel = String.localizedStringWithFormat("Bus %@".localized, busses[indexPath.row].name)
                busStopCell.finalStopLabel.text = String.localizedStringWithFormat(NSLocalizedString("Destination: %@", comment: ""), busses[indexPath.row].finalStop)
                //				busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"


                if let distance = busses[indexPath.row].distanceToUser {
                    if distance > 1000 {
                        busStopCell.distanceLabel.text = String.localizedStringWithFormat(NSLocalizedString("%.2f km away", comment: "Show how far the bus is away, in km (abbreviated)"), distance / 1000)
                    } else {
                        busStopCell.distanceLabel.text = "\(Int(distance))" + NSLocalizedString("m away", comment: "Distance to bus, in meters (abbreviated)")
                    }
                }

                return busStopCell
            }

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

            if let busStopCell = cell as? BusSelectionTableViewCell {
                busStopCell.busNumberLabel.text = busses[indexPath.row].name
                busStopCell.busNumberLabel.accessibilityLabel = String.localizedStringWithFormat("Bus %@".localized, busses[indexPath.row].name)

                busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"
                return busStopCell
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appDelegate = appDelegate else { return }
        appDelegate.busController.currentUserBus = busses[indexPath.row]


        performSegue(withIdentifier: "showBusDetailViewController", sender: nil)
        appDelegate.busController.runNow()
    }




    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


}


extension BusSelectionTableViewController : ApplicationEventHandler {
    func handleEvent(_ event: ApplicationEvent) {
        if event == .userLocationDidUpdate {
            didUpdateUserLocation()
        }
    }
}
