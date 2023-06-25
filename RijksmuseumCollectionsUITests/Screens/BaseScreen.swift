//
//  BaseScreen.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

class BaseScreen {

    let app = XCUIApplication()

    var buttons: XCUIElementQuery { app.buttons }
    var textFields: XCUIElementQuery { app.textFields }
    var staticTexts: XCUIElementQuery { app.staticTexts }
    var searchFields: XCUIElementQuery { app.searchFields }
    var cells: XCUIElementQuery { app.cells }
    var images: XCUIElementQuery { app.images }
    var otherElements: XCUIElementQuery { app.otherElements }
    var navigationBars: XCUIElementQuery { app.navigationBars }

    func staticTextElement(with text: String) -> XCUIElement {
        staticTexts[text]
    }

    func cell(with identifier: String) -> XCUIElement {
        cells[identifier]
    }

    func coverImageView(for cellIdentifier: String, imageIdentifier: String) -> XCUIElement {
        cells[cellIdentifier].images[imageIdentifier]
    }

    func titleLabel(for cellIdentifier: String, titleIdentifier: String) -> XCUIElement {
        cells[cellIdentifier].staticTexts[titleIdentifier]
    }

    func otherElement(for cellIdentifier: String, elementIdentifier: String) -> XCUIElement {
        cells[cellIdentifier].otherElements[elementIdentifier]
    }

    func searchField(with identifier: String) -> XCUIElement {
        searchFields[identifier]
    }
}
