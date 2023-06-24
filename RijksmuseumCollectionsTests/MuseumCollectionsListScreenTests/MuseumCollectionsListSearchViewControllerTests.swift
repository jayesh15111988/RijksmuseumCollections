//
//  MuseumCollectionsListSearchViewControllerTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class MuseumCollectionsListSearchViewControllerTests: XCTestCase {

    var alertDisplayableUtility: MockAlertDisplayUtility!

    override func setUp() {
        super.setUp()
        alertDisplayableUtility = MockAlertDisplayUtility()
    }

    func testThatViewControllerSetsCorrectStateWhenDataIsSuccessfullyLoaded() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        let museumCollectionsListSearchViewController = MuseumCollectionsListSearchViewController(alertDisplayUtility: alertDisplayableUtility, viewModel: museumCollectionsListSearchViewModel)

        museumCollectionsListSearchViewController.searchBar.text = "Monet"

        _ = museumCollectionsListSearchViewController.view

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        let expectation = XCTestExpectation(description: "View controller state is set to success")

        DispatchQueue.main.async {
            if case .success = museumCollectionsListSearchViewModel.loadingState {
                XCTAssertTrue(museumCollectionsListSearchViewController.userInfoLabelParentView.isHidden)
                XCTAssertFalse(museumCollectionsListSearchViewController.collectionView.isHidden)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testThatViewControllerSetsCorrectStateWhenDataLoadFails() {
        let networkService = MockRequestHandler()
        networkService.toFail = true
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        let museumCollectionsListSearchViewController = MuseumCollectionsListSearchViewController(alertDisplayUtility: alertDisplayableUtility, viewModel: museumCollectionsListSearchViewModel)

        museumCollectionsListSearchViewController.searchBar.text = "Monet"

        _ = museumCollectionsListSearchViewController.view

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        let expectation = XCTestExpectation(description: "View controller state is set to failure")

        DispatchQueue.main.async {
            if case .failure = museumCollectionsListSearchViewModel.loadingState {
                XCTAssertEqual(self.alertDisplayableUtility.shownTitle, "Error")
                XCTAssertEqual(self.alertDisplayableUtility.shownMessage, "Something went wrong while loading a request")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testThatViewControllerSetsCorrectStateWhenEmptyDataIsLoaded() {
        let networkService = MockRequestHandler()
        networkService.toSendEmptyResponse = true
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        let museumCollectionsListSearchViewController = MuseumCollectionsListSearchViewController(alertDisplayUtility: alertDisplayableUtility, viewModel: museumCollectionsListSearchViewModel)

        museumCollectionsListSearchViewController.searchBar.text = "Monet"

        _ = museumCollectionsListSearchViewController.view

        museumCollectionsListSearchViewModel.searchCollections(with: "Monet")

        let expectation = XCTestExpectation(description: "View controller state is set to empty")

        DispatchQueue.main.async {
            if case .emptyResult = museumCollectionsListSearchViewModel.loadingState {
                XCTAssertEqual(museumCollectionsListSearchViewController.userInfoLabel.text, "No art objects found matching current search keyword. Please try searching with another keyword")
                XCTAssertFalse(museumCollectionsListSearchViewController.userInfoLabelParentView.isHidden)
                XCTAssertTrue(museumCollectionsListSearchViewController.collectionView.isHidden)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testThatViewControllerSetsCorrectStateWhenNoTextIsEnteredInSearchField() {
        let networkService = MockRequestHandler()
        let museumCollectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: networkService)

        let museumCollectionsListSearchViewController = MuseumCollectionsListSearchViewController(alertDisplayUtility: alertDisplayableUtility, viewModel: museumCollectionsListSearchViewModel)

        museumCollectionsListSearchViewController.searchBar.text = "Monet"

        _ = museumCollectionsListSearchViewController.view

        museumCollectionsListSearchViewController.searchBar(museumCollectionsListSearchViewController.searchBar, textDidChange: "")
        XCTAssertEqual(museumCollectionsListSearchViewController.userInfoLabel.text, "Please start typing keyword in the search box to view the list of collections in Rijksmuseum")
        XCTAssertFalse(museumCollectionsListSearchViewController.userInfoLabelParentView.isHidden)
        XCTAssertTrue(museumCollectionsListSearchViewController.collectionView.isHidden)
    }
}
