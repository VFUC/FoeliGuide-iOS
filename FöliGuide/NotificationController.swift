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
		let title = NSLocalizedString("Destination upcoming!", comment: "Destination upcoming! (Let the user know he's almost there)")
		let body = String.localizedStringWithFormat(NSLocalizedString("Next stop is %@", comment: "Name the bus station the user is about to arrive at"), stopName)
		notificationWithTitle(title, body: body, viewController: viewController)
	}
	
	
	class func showAfterThatBusStationNotification(stopName stopName: String, viewController: UIViewController){
		let title = NSLocalizedString("Arriving soon!", comment: "Arriving soon! (Let the user know he's almost there)")
		let body = String.localizedStringWithFormat(NSLocalizedString("%@ is only 2 stops away", comment: "Name the bus station the user is going to arrive at soon"), stopName)
		notificationWithTitle(title, body: body, viewController: viewController)
	}
	
	
	
	private class func notificationWithTitle(title: String, body: String, viewController: UIViewController){
		
		let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
		viewController.presentViewController(alertController, animated: true, completion: nil)
	}
	
	class func showAppInBackgroundWithAlarmWarning(){
		let notification = UILocalNotification()
		
		notification.alertTitle = "Your alarm is still set!"
		notification.alertBody = "Bus station alarms do not work when app is in background"
		UIApplication.sharedApplication().presentLocalNotificationNow(notification)
	}
	
	
}
