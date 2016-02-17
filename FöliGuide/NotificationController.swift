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
		
		notificationWithTitle("Destination upcoming!", body: "Next stop is \(stopName)", viewController: viewController)
	}
	
	
	class func showAfterThatBusStationNotification(stopName stopName: String, viewController: UIViewController){
		notificationWithTitle("Arriving soon!", body: "\(stopName) is only 2 stops away", viewController: viewController)
	}
	
	
	
	private class func notificationWithTitle(title: String, body: String, viewController: UIViewController){
		
		let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate) //TODO: Sound too, not only vibration
		viewController.presentViewController(alertController, animated: true, completion: nil)
	
	}
	
	class func showAppInBackgroundWithAlarmWarning(){
		let notification = UILocalNotification()
		
		notification.alertTitle = "Your alarm is still set!"
		notification.alertBody = "Bus station alarms do not work when app is in background"
		UIApplication.sharedApplication().presentLocalNotificationNow(notification)
	}
	
	
}
