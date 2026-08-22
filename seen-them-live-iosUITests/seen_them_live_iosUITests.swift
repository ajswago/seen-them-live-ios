//
//  seen_them_live_iosUITests.swift
//  seen-them-live-iosUITests
//
//  Created by Anthony Swago on 7/17/26.
//

import XCTest

final class seen_them_live_iosUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testLoginScreenElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify "Seen Them Live" title is present
        let titleText = app.staticTexts["Seen Them Live"]
        XCTAssertTrue(titleText.exists)

        // Verify description text is present
        let descText = app.staticTexts["Track your concert history in one place"]
        XCTAssertTrue(descText.exists)

        // Verify "Sign in with Google" button is present
        let googleButton = app.buttons["Sign in with Google"]
        XCTAssertTrue(googleButton.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
