//
//  ARCUITests.swift
//  ARCUITests
//
//  Created by Daniel Ryu on 2/2/23.
//

import XCTest

class ARCUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMain() {
        let app = XCUIApplication()
        app.launch()
        
        // These buttons should exist
        let profileButton = app.buttons["Profile"]
        let libraryButton = app.buttons["Library"]
        let recordButton = app.buttons["Record"]
        let effectsButton = app.buttons["Effects"]
        
        XCTAssertTrue(profileButton.exists)
        XCTAssertTrue(libraryButton.exists)
        XCTAssertTrue(recordButton.exists)
        XCTAssertTrue(effectsButton.exists)
    }

    func testBackButton() {
        let app = XCUIApplication()
        app.launch()
        
        let button = app.buttons["Profile"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.exists)
        
        backButton.tap()
        
        XCTAssertTrue(app.buttons["Effects"].exists)
    }
    
    func testSignup() {
        let app = XCUIApplication()
        app.launch()
                                
        let button = app.buttons["Profile"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        let login = app.buttons["LOGIN"]
        if (!login.exists) {
            return
        }
        
        let toSignup  = app.buttons["toSignup"]
        XCTAssertTrue(toSignup.exists)
        
        toSignup.tap()
        
        let signup = app.buttons["signup"]
        XCTAssertTrue(signup.exists)
    }
    
    func testSignupVC() {
        let app = XCUIApplication()
        app.launch()
                                
        let button = app.buttons["Profile"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        let signup = app.buttons["Sign Up"]
        if (!signup.exists) {
            return
        }
        
        signup.tap()
        
        debugPrint(app.buttons)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
