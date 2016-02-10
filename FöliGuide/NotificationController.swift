//
//  NotificationController.swift
//  FöliGuide
//
//  Created by Jonas on 09/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import AudioToolbox

class NotificationController: NSObject {
	
	
	class func showNextBusStationNotification(stopName stopName: String, viewController: UIViewController){
		
		let notification = UILocalNotification()
		
		notification.alertTitle = "Destination upcoming!"
		notification.alertBody = "Next stop is \(stopName)"
		
//		UIApplication.sharedApplication().presentLocalNotificationNow(notification)
		
		let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate) //TODO: Sound too, not only vibration
		viewController.presentViewController(alertController, animated: true, completion: nil)
	}
	
}
