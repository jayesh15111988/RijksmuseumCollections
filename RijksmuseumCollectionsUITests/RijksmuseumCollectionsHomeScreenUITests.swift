//
//  RijksmuseumCollectionsHomeScreenUITests.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/22/23.
//

import XCTest

final class RijksmuseumCollectionsHomeScreenUITests: BaseTest {

    var collectionsListSearchScreen: MuseumCollectionsListSearchScreen!

    override func setUp() {
        super.setUp()
        self.collectionsListSearchScreen = MuseumCollectionsListSearchScreen()
    }

    func testThatTopNavigationTitleExists() {
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Rijksmuseum Collection").exists)
    }

    func testInitialState() {
        XCTAssertTrue(collectionsListSearchScreen.searchField(with: "objectsListScreen.searchField").exists)
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists)
    }

    func testThatUserCanSearchWithKeywordsWithResults() {

        collectionsListSearchScreen
            .performSearch(with: "Rembrandt")

        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Collection Items").exists)
        XCTAssertTrue(collectionsListSearchScreen.cells.count > 0)

        XCTAssertTrue(collectionsListSearchScreen.cell(with: "objectsListScreen.artObjectCell.0").isHittable)

        XCTAssertTrue(collectionsListSearchScreen.coverImageView(for: "objectsListScreen.artObjectCell.0", imageIdentifier: "artObjectCell.coverImage").exists)

        XCTAssertTrue(collectionsListSearchScreen.titleLabel(for: "objectsListScreen.artObjectCell.0", titleIdentifier: "artObjectCell.artObjectTitle").exists)

        XCTAssertTrue(collectionsListSearchScreen.otherElement(for: "objectsListScreen.artObjectCell.0", elementIdentifier: "artObjectCell.horizontalDivider").exists)
    }

    func testThatUserCanSearchWithKeywordsWithNoResults() {
        collectionsListSearchScreen
            .performSearch(with: "adasdfsdfdsfsdfdsf")

        XCTAssertTrue(collectionsListSearchScreen.searchField(with: "objectsListScreen.searchField").exists)
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "No art objects found matching current search keyword. Please try searching with another keyword").exists)     
    }

    func testThatUserCanClearSearchFieldAndViewInformationMessage() {
        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists)

        collectionsListSearchScreen
            .performSearch(with: "Rembrandt")

        XCTAssertFalse(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists)

        collectionsListSearchScreen.clearSearchField()

        XCTAssertTrue(collectionsListSearchScreen.staticTextElement(with: "Please start typing keyword in the search box to view the list of collections in Rijksmuseum").exists)
    }
}
