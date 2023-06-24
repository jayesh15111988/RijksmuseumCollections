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
        XCTAssertEqual(ArtObjectCollectionViewCell.reuseIdentifier, "ArtObjectCollectionViewCell")
        XCTAssertEqual(ArtObjectCollectionViewSectionHeaderView.reuseIdentifier, "ArtObjectCollectionViewSectionHeaderView")
    }
}
