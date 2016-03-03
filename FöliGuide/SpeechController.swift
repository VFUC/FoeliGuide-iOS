//
//  SpeechController.swift
//  FöliGuide
//
//  Created by Jonas on 03/03/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import AVFoundation






class SpeechController: NSObject {
	
	static let speechSynthesizer = AVSpeechSynthesizer()
	
	class func speakString(string: String){
		let utterance = AVSpeechUtterance(string: string)
		speechSynthesizer.speakUtterance(utterance)
	}
	
	
	class func announceNextBusStop(busStop: String){
		let nextStopUtterance = AVSpeechUtterance(string: "Next Stop")
		let stopUtterance = AVSpeechUtterance(string: busStop)
		stopUtterance.rate = 0.4
		stopUtterance.voice = AVSpeechSynthesisVoice(language: "fi-FI")
		
		speechSynthesizer.speakUtterance(nextStopUtterance)
		speechSynthesizer.speakUtterance(stopUtterance)
	}
	
	class func announceFollowingBusStop(busStop: String){
		let afterThatUtterance = AVSpeechUtterance(string: "After that")
		let stopUtterance = AVSpeechUtterance(string: busStop)
		stopUtterance.rate = 0.4
		stopUtterance.voice = AVSpeechSynthesisVoice(language: "fi-FI")
		
		speechSynthesizer.speakUtterance(afterThatUtterance)
		speechSynthesizer.speakUtterance(stopUtterance)
	}
	
}
