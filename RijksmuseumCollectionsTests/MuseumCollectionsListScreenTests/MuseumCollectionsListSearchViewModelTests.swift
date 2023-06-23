//
//  MuseumCollectionsListSearchViewModelTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

@testable import RijksmuseumCollections

public typealias LoadingState = MuseumCollectionsListSearchViewModel.LoadingState

final class MuseumCollectionsListSearchViewModelTests: XCTestCase {

    func testThatMuseumCollectionsListSearchViewModelSetsStateToSuccessOnSuccessfulFetch() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        XCTAssertEqual(museumCollectionsListSearchViewModel.loadingState, .idle)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        XCTAssertEqual(museumCollectionsListSearchViewModel.currentSearchKeyword, "Monet")
        XCTAssertEqual(museumCollectionsListSearchViewModel.totalNumberOfObjects, 20)

        if case let .success(artObjectViewModels) = museumCollectionsListSearchViewModel.loadingState {
            XCTAssertEqual(artObjectViewModels.count, 10)
            if let firstArtObjectViewModel = artObjectViewModels.first {
                //TODO:
                XCTAssertEqual(firstArtObjectViewModel.id, "nl-BK-2018-2-163-2")
                XCTAssertEqual(firstArtObjectViewModel.title, "Paar oorclips van verguld koper")
                XCTAssertEqual(firstArtObjectViewModel.longTitle, "Paar oorclips van verguld koper, Monet, ca. 1970 - ca. 1980")
                XCTAssertEqual(firstArtObjectViewModel.productionPlacesList, "Parijs")
                XCTAssertEqual(firstArtObjectViewModel.webImageURL, "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0")
                XCTAssertEqual(firstArtObjectViewModel.headerImageURL, "https://lh3.googleusercontent.com/FiDD3r3nThrcC6NlXjPNgw5WGoEUr9KVeEfZxZWBMNQlcI4Ds8RhyXHjzGhE4x_JktqD_M_UUcn0Oc7NB2eJL-IrFJLVeKOdIkCIukEl1g=s0")
                XCTAssertEqual(firstArtObjectViewModel.makerName, "Monet")
                XCTAssertEqual(firstArtObjectViewModel.shortDescription, "Paar oorclips van verguld koper By Monet")
            } else {
                XCTFail("Failed to get art object view model from the list. Expected at least one view model")
            }
        } else {
            XCTFail("Failed to get expected loading state from view model state. Expected loading state. Got \(museumCollectionsListSearchViewModel.loadingState)")
        }
        XCTAssertTrue(museumCollectionsListSearchViewModel.toLoadMoreCollections)
    }

    func testThatMuseumCollectionsListSearchViewModelSetsStateToFailureOnError() {

    }

    func testThatMuseumCollectionsListSearchViewModelSetsStateToEmptyOnEmptyResponse() {

    }
}

extension LoadingState: Equatable {
    public static func ==(lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.emptyResult, .emptyResult):
            return true
        case (let .success(lhsViewModels), let .success(rhsViewModels)):
            return lhsViewModels == rhsViewModels
        case (let .failure(lhsMessage), let .failure(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
