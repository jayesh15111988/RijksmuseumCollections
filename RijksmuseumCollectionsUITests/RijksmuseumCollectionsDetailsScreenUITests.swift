//
//  RijksmuseumCollectionsDetailsScreenUITests.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

final class RijksmuseumCollectionsDetailsScreenUITests: BaseTest {

    override func setUp() {
        super.setUp()
    }

    func testThatUserCanLandOnAndVerifyAllInformationOnDetailsPage() {

        let collectionsListSearchScreen = MuseumCollectionsListSearchScreen()

        collectionsListSearchScreen
            .performSearch(with: "Picasso")
            .tapCell(with: "objectsListScreen.artObjectCell.0")

        let museumCollectionsDetailsScreen = MuseumCollectionsDetailsScreen()

        XCTAssertTrue(museumCollectionsDetailsScreen.navigationTitle.exists)
        XCTAssertTrue(museumCollectionsDetailsScreen.webImageView.exists)
        XCTAssertTrue(museumCollectionsDetailsScreen.longTitle.exists)
        XCTAssertTrue(museumCollectionsDetailsScreen.productionPlaces.exists)
        XCTAssertTrue(museumCollectionsDetailsScreen.artistLabel.exists)
    }
}
