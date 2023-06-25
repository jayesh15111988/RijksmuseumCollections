//
//  ReuseIdentifierGeneratorTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class ReuseIdentifierGeneratorTests: XCTestCase {

    func testThatReusableViewCorrectlyGeneratesReuseIdentifier() {
        XCTAssertEqual(ArtObjectCollectionViewCell.reuseIdentifier, "ArtObjectCollectionViewCell", "The reuseIdentifier of ArtObjectCollectionViewCell is incorrect")
        XCTAssertEqual(ArtObjectCollectionViewSectionHeaderView.reuseIdentifier, "ArtObjectCollectionViewSectionHeaderView", "The reuseIdentifier of ArtObjectCollectionViewSectionHeaderView is incorrect")
    }
}
