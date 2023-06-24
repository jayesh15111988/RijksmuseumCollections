//
//  ArtObjectCollectionViewSectionHeaderViewTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class ArtObjectCollectionViewSectionHeaderViewTests: XCTestCase {

    func testThatArtObjectCollectionViewSectionHeaderViewConfiguresBasedOnPassedViewModel() {

        let headerView = ArtObjectCollectionViewSectionHeaderView(frame: .zero)
        headerView.configure(with: "Test Header Text")

        XCTAssertEqual(headerView.topTitleLabel.text, "Test Header Text")

        headerView.prepareForReuse()
        XCTAssertNil(headerView.topTitleLabel.text)
    }
}
