//
//  BaseTest.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/25/23.
//

import XCTest

// Base test from which all the other tests will inherit
// We will use it to execute common operations applicable on app startup
class BaseTest: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }
}
