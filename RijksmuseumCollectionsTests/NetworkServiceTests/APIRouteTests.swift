//
//  APIRouteTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class APIRouteTests: XCTestCase {

    func testThatAPIRouteCorrectlySetsURLRequestBasedOnPassedCase() {
        let apiRoute = APIRoute.getCollectionsList(searchKeyword: "Picasso", pageNumber: 1)

        let urlRequest = apiRoute.asRequest()
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Picasso&p=1")
    }
}
