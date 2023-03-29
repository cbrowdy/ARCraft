//
//  ARCTests.swift
//  ARCTests
//
//  Created by Daniel Ryu on 2/2/23.
//

import XCTest
@testable import ARC

class ARCTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEffectCell() {
        let effect = EffectsCell()
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        effect.selectedView = view
        
        XCTAssertTrue(effect.selectedView != nil)
        
        // Test select
        let color0 = view.backgroundColor
        effect.select()
        XCTAssertTrue(effect.selectedView.backgroundColor != color0)
        
        // Test deselect
        let color1 = view.backgroundColor
        effect.deselect()
        XCTAssertTrue(effect.selectedView.backgroundColor != color0)
        XCTAssertTrue(effect.selectedView.backgroundColor != color1)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
