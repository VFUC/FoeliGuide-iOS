//
//  BusSelectionCollectionViewController.swift
//  FöliGuide
//
//  Created by Jonas on 08/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let reuseIdentifierHorizontal = "CellHorizontal"
private let reuseIdentifierSectionHeader = "Header"

class BusSelectionCollectionViewController: UICollectionViewController {
	
	var busses = [Bus]()
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var headerView: BusSelectionHeaderCollectionReusableView?
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
    override func viewDidLoad() {
        super.viewDidLoad()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		activityIndicator.startAnimating()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		activityIndicator.stopAnimating()
		headerView?.showLoadingLocationState()
//		appDelegate.busSelectionVC = self // should be here, so appDelegate reloads user data
		loadData()
	}
	
	
	
	func loadData(){
		if let currentBusData = appDelegate.busController.currentBusData {
			busses = currentBusData
		}
		
//		if let currentUserLocation = appDelegate.locationController.userLocation {
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)
//		}
		
		collectionView?.reloadData()
	}
	
	func didUpdateUserLocation(){
//		if let currentUserLocation = appDelegate.locationController?.userLocation {
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)
			headerView?.showNormalState()
//		}
		collectionView?.reloadData()
	}
	
	
	
	
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busses.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		/*
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		if let busStopCell = cell as? BusSelectionCollectionViewCell {
			busStopCell.numberLabel.text = busses[indexPath.row].name
			busStopCell.finalStopLabel.text = busses[indexPath.row].finalStop
//			busStopCell.finalStopLabel.text = "\(Int(busses[indexPath.row].distanceToUser!))"
			return busStopCell
		} 
		
		*/
		
		
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierHorizontal, for: indexPath)
		
		if let busStopCell = cell as? BusSelectionHorizontalCollectionViewCell {
		busStopCell.numberLabel.text = busses[indexPath.row].name
		busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"
		busStopCell.distanceLabel.text = "\(Int(busses[indexPath.row].distanceToUser ?? -1))m away"
		return busStopCell
		}
		
		
        return cell
    }
	
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierSectionHeader, for: indexPath)
		
		if let header = reusableView as? BusSelectionHeaderCollectionReusableView {
			headerView = header
		}
		
		return reusableView
	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
	
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! BusSelectionCollectionViewCell
		cell.selectionAnimation()
		
		appDelegate.busController.currentUserBus = busses[indexPath.row]
		
		performSegue(withIdentifier: "showNextBusStop", sender: nil)
	}

}
