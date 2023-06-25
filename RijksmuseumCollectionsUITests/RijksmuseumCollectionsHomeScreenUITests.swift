//
//  RijksmuseumCollectionsHomeScreenUITests.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/22/23.
//

import XCTest

final class RijksmuseumCollectionsHomeScreenUITests: BaseTest {

    override func setUp() {
        super.setUp()
    }

    func testThatTopNavigationTitleExists() {
        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Rijksmuseum Collection").exists, "The fix title on app home screen should be visible")
    }

    func testInitialState() {
        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
        XCTAssertTrue(collectionsListSearchScreen.searchField(with: "objectsListScreen.searchField").exists, "App should have search field on the home page")
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists, "Search field should display informational placeholder text")
    }

    func testThatUserCanSearchWithKeywordsWithResults() {
        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
        collectionsListSearchScreen
            .performSearch(with: "Rembrandt")

        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Collection Items").exists, "App should display list section header title")
        XCTAssertTrue(collectionsListSearchScreen.cells.count > 0, "App should display non-zero number of art objects for valid search keyword")

        XCTAssertTrue(collectionsListSearchScreen.cell(with: "objectsListScreen.artObjectCell.0").isHittable, "Collection view cell corresponding to art object should be tappable")

        XCTAssertTrue(collectionsListSearchScreen.coverImageView(for: "objectsListScreen.artObjectCell.0", imageIdentifier: "artObjectCell.coverImage").exists, "The object cell should have cover image view visible")

        XCTAssertTrue(collectionsListSearchScreen.titleLabel(for: "objectsListScreen.artObjectCell.0", titleIdentifier: "artObjectCell.artObjectTitle").exists, "The object cell should have title visible")

        XCTAssertTrue(collectionsListSearchScreen.otherElement(for: "objectsListScreen.artObjectCell.0", elementIdentifier: "artObjectCell.horizontalDivider").exists, "The object cell should have horizontal divider visible")
    }

    func testThatUserCanSearchWithKeywordsWithNoResults() {
        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
        collectionsListSearchScreen
            .performSearch(with: "adasdfsdfdsfsdfdsf")

        XCTAssertTrue(collectionsListSearchScreen.searchField(with: "objectsListScreen.searchField").exists, "App should have search field on the home page")
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "No art objects found matching current search keyword. Please try searching with another keyword").exists, "App should display correct informational message when API cannot find any results for given keyword")
    }

    func testThatUserCanClearSearchFieldAndViewInformationMessage() {
        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists, "App should display default informational message in the beginning")

        collectionsListSearchScreen
            .performSearch(with: "Rembrandt")

        XCTAssertFalse(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists, "App should not display default informational message after search results are back")

        collectionsListSearchScreen.clearSearchField()

        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists, "App should display informational message about how to perform search for art objects")
    }
}
