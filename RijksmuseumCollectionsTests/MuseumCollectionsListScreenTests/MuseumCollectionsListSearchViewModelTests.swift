//
//  MuseumCollectionsListSearchViewModelTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

@testable import RijksmuseumCollections

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
            XCTFail("Failed to get expected loading state from view model state. Expected success state. Got \(museumCollectionsListSearchViewModel.loadingState)")
        }
        XCTAssertTrue(museumCollectionsListSearchViewModel.toLoadMoreCollections)
    }

    func testThatMuseumCollectionsListSearchViewModelSetsStateToFailureOnError() {
        let networkService = MockRequestHandler()
        networkService.toFail = true
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        XCTAssertEqual(museumCollectionsListSearchViewModel.loadingState, .idle)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        if case let .failure(errorMessage) = museumCollectionsListSearchViewModel.loadingState {
            XCTAssertEqual(errorMessage, "Something went wrong while loading a request")
        } else {
            XCTFail("Failed to get expected loading state from view model state. Expected failure state. Got \(museumCollectionsListSearchViewModel.loadingState)")
        }
    }

    func testThatMuseumCollectionsListSearchViewModelSetsStateToEmptyOnEmptyResponse() {
        let networkService = MockRequestHandler()
        networkService.toSendEmptyResponse = true
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        XCTAssertEqual(museumCollectionsListSearchViewModel.loadingState, .idle)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        if case .emptyResult = museumCollectionsListSearchViewModel.loadingState {
            //Do nothing. If we came here, that means we successfully passed the test
        } else {
            XCTFail("Failed to get expected loading state from view model state. Expected emptyResult state. Got \(museumCollectionsListSearchViewModel.loadingState)")
        }
    }

    func testThatViewModelCorrectlyResetsTheSearchState() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        XCTAssertEqual(museumCollectionsListSearchViewModel.loadingState, .idle)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        XCTAssertTrue(museumCollectionsListSearchViewModel.toLoadMoreCollections)

        museumCollectionsListSearchViewModel.loadNextPage()

        XCTAssertEqual(museumCollectionsListSearchViewModel.currentPageNumber, 2)
        XCTAssertFalse(museumCollectionsListSearchViewModel.toLoadMoreCollections)
        XCTAssertEqual(museumCollectionsListSearchViewModel.totalNumberOfObjects, 20)
        XCTAssertEqual(museumCollectionsListSearchViewModel.artObjectViewModels.count, 20)

        museumCollectionsListSearchViewModel.resetSearchState()

        XCTAssertEqual(museumCollectionsListSearchViewModel.currentPageNumber, 1)
        XCTAssertTrue(museumCollectionsListSearchViewModel.toLoadMoreCollections)
        XCTAssertEqual(museumCollectionsListSearchViewModel.totalNumberOfObjects, 0)
        XCTAssertTrue(museumCollectionsListSearchViewModel.artObjectViewModels.isEmpty)
    }

    func testThatViewModelCorrectlyDeterminesToLoadNextPage() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        museumCollectionsListSearchViewModel.loadNextPage()

        XCTAssertTrue(museumCollectionsListSearchViewModel.toLoadNextPage(currentCellIndex: 5))

    }

    func testThatViewModelCorrectlyDeterminesToNotLoadNextPage() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        museumCollectionsListSearchViewModel.loadNextPage()

        XCTAssertFalse(museumCollectionsListSearchViewModel.toLoadNextPage(currentCellIndex: 2))
    }

    func testEqualityOfArtObjectViewModelObjects() {
        let artObjectViewModelOne = ArtObjectViewModel(id: "100", title: "This title", longTitle: "long title", productionPlacesList: "Amsterdam", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of value")

        let artObjectViewModelTwo = ArtObjectViewModel(id: "100", title: "This title is short", longTitle: "another long title", productionPlacesList: "Boston", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of low value")

        XCTAssertTrue(artObjectViewModelOne == artObjectViewModelTwo)
    }

    func testInequalityOfArtObjectViewModelObjects() {
        let artObjectViewModelOne = ArtObjectViewModel(id: "100", title: "This title", longTitle: "long title", productionPlacesList: "Amsterdam", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of value")

        let artObjectViewModelTwo = ArtObjectViewModel(id: "200", title: "This title is short", longTitle: "another long title", productionPlacesList: "Boston", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of low value")

        XCTAssertFalse(artObjectViewModelOne == artObjectViewModelTwo)
    }

    func testLoadingStateEquality() {

        let idleStateOne: LoadingState = .idle
        let idleStateTwo: LoadingState = .idle

        let loadingStateOne: LoadingState = .loading
        let loadingStateTwo: LoadingState = .loading

        let emptyResultStateOne: LoadingState = .emptyResult
        let emptyResultStateTwo: LoadingState = .emptyResult

        let successfulLoadStateOne: LoadingState = .success(viewModels: [ArtObjectViewModel(id: "100", title: "This title", longTitle: "long title", productionPlacesList: "Amsterdam", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of value")])

        let successfulLoadStateTwo: LoadingState = .success(viewModels: [ArtObjectViewModel(id: "100", title: "This title is short", longTitle: "another long title", productionPlacesList: "Boston", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of low value")])

        let successfulLoadStateThree: LoadingState = .success(viewModels: [ArtObjectViewModel(id: "200", title: "This title is short", longTitle: "another long title", productionPlacesList: "Boston", webImageURL: nil, headerImageURL: nil, makerName: nil, shortDescription: "Object of low value")])

        let failureStateOne: LoadingState = .failure(errorMessage: "Unexpected Error")
        let failureStateTwo: LoadingState = .failure(errorMessage: "Unexpected Error")
        let failureStateThree: LoadingState = .failure(errorMessage: "Something went wrong")

        XCTAssertEqual(idleStateOne, idleStateTwo)
        XCTAssertEqual(loadingStateOne, loadingStateTwo)
        XCTAssertEqual(emptyResultStateOne, emptyResultStateTwo)

        XCTAssertNotEqual(idleStateOne, loadingStateOne)
        XCTAssertNotEqual(loadingStateOne, emptyResultStateOne)
        XCTAssertNotEqual(emptyResultStateOne, successfulLoadStateOne)
        XCTAssertNotEqual(successfulLoadStateOne, failureStateOne)
        XCTAssertNotEqual(failureStateOne, idleStateOne)

        XCTAssertEqual(successfulLoadStateOne, successfulLoadStateTwo)
        XCTAssertNotEqual(successfulLoadStateTwo, successfulLoadStateThree)

        XCTAssertEqual(failureStateOne, failureStateTwo)
        XCTAssertNotEqual(failureStateTwo, failureStateThree)
    }

    func testThatViewModelCanSendSuccessiveRequestsToLoadNextPage() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        XCTAssertEqual(networkService.lastRequestedURL, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Monet&p=1")

        museumCollectionsListSearchViewModel.loadNextPage()

        XCTAssertEqual(networkService.lastRequestedURL, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Monet&p=2")
    }

    func testThatViewModelCanRetryPreviousRequest() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        XCTAssertEqual(networkService.lastRequestedURL, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Monet&p=1")

        museumCollectionsListSearchViewModel.loadNextPage()

        XCTAssertEqual(networkService.lastRequestedURL, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Monet&p=2")

        museumCollectionsListSearchViewModel.retryLastRequest()
        XCTAssertEqual(networkService.lastRequestedURL, "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Monet&p=2")
    }
}
