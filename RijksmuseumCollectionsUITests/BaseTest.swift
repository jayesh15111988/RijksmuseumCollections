//
//  BaseTest.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/25/23.
//

import XCTest

class BaseTest: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }
}
