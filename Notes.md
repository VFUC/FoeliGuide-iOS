#### CoreLocation

> If your iOS app must keep monitoring location even while it’s in the background, use the standard location service and specify the location value of the UIBackgroundModes key to continue running in the background and receiving location updates. (In this situation, you should also make sure the location manager’s pausesLocationUpdatesAutomatically property is set to YES to help conserve power.) Examples of apps that might need this type of location updating are fitness or turn-by-turn navigation apps.

...

> it’s recommended that you always call the locationServicesEnabled class method of CLLocationManager before attempting to start either the standard or significant-change location services. If it returns NO and you attempt to start location services anyway, the system prompts the user to confirm whether location services should be re-enabled. Because the user probably disabled location services on purpose, the prompt is likely to be unwelcome.

