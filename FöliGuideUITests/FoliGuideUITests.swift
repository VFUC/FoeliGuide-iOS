//
//  Fo_liGuideUITests.swift
//  FöliGuideUITests
//
//  Created by Jonas on 21/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import XCTest

class FoliGuideUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        setupSnapshot(app)
        app.launch()
    }

    //	let localizationBundle = NSBundle(path: NSBundle(forClass: self).pathForResource(deviceLanguage, ofType: "lproj")!)
    //	/*3*/ let result = NSLocalizedString(key, bundle:localizationBundle!, comment: "") //

    func testExample() {
        //		snapshot("0Launch")

        let app = XCUIApplication()

        app.otherElements.containing(.navigationBar, identifier:"Fo_liGuide.MainView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 0).tap()
        app.tables.cells.element(boundBy: 0).tap()

        snapshot("BusDetailScreen")

        //Tap settings button
        //		app.navigationBars["Fo_liGuide.MainView"].buttons.elementBoundByIndex(0).tap()
        //		app.navigationBars["Fo_liGuide.MainView"].buttons[NSLocalizedString("Settings",bundle: NSBundle(forClass: Fo_liGuideUITests.self), comment:"")].tap()


        //		snapshot("1Settings")
        //tap done button
        //		let tablesQuery2 = app.tables
        //		tablesQuery2.buttons.elementBoundByIndex(0).tap()
        //		tablesQuery2.buttons["Done"].tap()





        //		snapshot("2BusSelectionScreen")


        //		snapshot("3BusDetailScreen")

        //		let foLiguideBusdetailviewNavigationBar = app.navigationBars["Fo_liGuide.BusDetailView"]
        //		foLiguideBusdetailviewNavigationBar.buttons["bell"].tap()
        //		app.navigationBars["Fo_liGuide.BusDetailView"].buttons[NSLocalizedString("Set an alarm",bundle: NSBundle(forClass: Fo_liGuideUITests.self) ,comment:"")].tap()


        //		snapshot("4DestinationSelectionScreen")


        //		tablesQuery.staticTexts["Urheilutie"].tap()
        //		foLiguideBusdetailviewNavigationBar.buttons["bell filled"].tap()
        //		app.alerts["Remove alarm?"].collectionViews.buttons["Remove"].tap()
        //		app.buttons["ios volume low"].tap()
        //		foLiguideBusdetailviewNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }

}
