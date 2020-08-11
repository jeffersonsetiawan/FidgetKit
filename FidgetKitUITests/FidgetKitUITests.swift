//
//  FidgetKitUITests.swift
//  FidgetKitUITests
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import XCTest

class FidgetKitUITests: XCTestCase {
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
