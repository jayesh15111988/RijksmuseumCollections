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

        XCTAssertTrue(museumCollectionsDetailsScreen.navigationTitle.exists, "App should display navigation title for details screen")
        XCTAssertTrue(museumCollectionsDetailsScreen.webImageView.exists, "Details screen should have image view visible")
        XCTAssertTrue(museumCollectionsDetailsScreen.longTitle.exists, "Details screen should have long title visible")
        XCTAssertTrue(museumCollectionsDetailsScreen.productionPlaces.exists, "Details screen should have production places view visible")
        XCTAssertTrue(museumCollectionsDetailsScreen.artistLabel.exists, "Details screen should have artist label visible")
    }
}
