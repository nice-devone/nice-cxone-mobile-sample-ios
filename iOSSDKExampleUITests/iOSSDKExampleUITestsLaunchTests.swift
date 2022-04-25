//
//  iOSSDKExampleUITestsLaunchTests.swift
//  iOSSDKExampleUITests
//
//  Created by Tyler Hendrickson on 1/27/22.
//

import XCTest

class iOSSDKExampleUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        // TODO: Figure out why this breaks when running in a pipeline
//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)
    }
}
