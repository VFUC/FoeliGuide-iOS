//
//  Fo_liGuideUITests.swift
//  FöliGuideUITests
//
//  Created by Jonas on 21/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import XCTest

class Fo_liGuideUITests: XCTestCase {
	
	let app = XCUIApplication()
	
    override func setUp() {
        super.setUp()
		
		setupSnapshot(app)
		app.launch()
    }
	
    
    func testExample() {
		snapshot("0Launch")
		app.navigationBars["Fo_liGuide.MainView"].buttons["gear icon barbuttonsize"].tap()
		
		snapshot("1Settings")
		let tablesQuery2 = app.tables
		tablesQuery2.buttons["Done"].tap()
		app.buttons["bus"].tap()
		
		snapshot("2BusSelectionScreen")
		
		app.tables.cells.elementBoundByIndex(0).tap()
		
		snapshot("3BusDetailScreen")
		
		let foLiguideBusdetailviewNavigationBar = app.navigationBars["Fo_liGuide.BusDetailView"]
		foLiguideBusdetailviewNavigationBar.buttons["bell"].tap()

		snapshot("4DestinationSelectionScreen")
		
		
		//		tablesQuery.staticTexts["Urheilutie"].tap()
//		foLiguideBusdetailviewNavigationBar.buttons["bell filled"].tap()
//		app.alerts["Remove alarm?"].collectionViews.buttons["Remove"].tap()
//		app.buttons["ios volume low"].tap()
//		foLiguideBusdetailviewNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }
	
}

