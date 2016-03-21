//
//  BusSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 19/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "BusCell"

class BusSelectionTableViewController: UITableViewController {

	var busses = [Bus]()
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	override func viewDidAppear(animated: Bool) {
		appDelegate.busSelectionVC = self
		loadData()
	}
	
	
	
	func loadData(){
		if let currentBusData = appDelegate.busController.currentBusData {
			busses = currentBusData
		}
		
		if let currentUserLocation = appDelegate.locationController?.userLocation {
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: currentUserLocation)
		}
		
		tableView.reloadData()
	}
	
	
	func didUpdateUserLocation(){
		if let currentUserLocation = appDelegate.locationController?.userLocation {
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: currentUserLocation)
		}
		tableView?.reloadData()
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busses.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)

		
		if let busStopCell = cell as? BusSelectionTableViewCell {
			busStopCell.busNumberLabel.text = busses[indexPath.row].name
			busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"
			
			if let distance = busses[indexPath.row].distanceToUser {
				if distance > 1000 {
					busStopCell.distanceLabel.text = String(format: "%.2f km away", distance / 1000)
				} else {
					busStopCell.distanceLabel.text = "\(Int(distance))m away"
				}
			} else {
				busStopCell.distanceLabel.text = ""
			}
			
			
			return busStopCell
		}

        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		appDelegate.busController.currentUserBus = busses[indexPath.row]
		
		
		appDelegate.busController.getBusRoute(forBus: appDelegate.busController.currentUserBus!) { (busStops) -> () in
			guard busStops != nil else {
				//TODO: show user error (?)
				
				//fall back to next/afterthat view
				self.performSegueWithIdentifier("showNextBusStopController", sender: nil)
				return
			}
			self.appDelegate.busController.currentUserBus?.route = busStops
			
			self.performSegueWithIdentifier("showBusRouteController", sender: nil)
		}
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
