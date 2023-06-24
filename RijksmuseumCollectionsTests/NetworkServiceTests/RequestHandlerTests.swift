//
//  RequestHandlerTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class RequestHandlerTests: XCTestCase {

    var mockSession: URLSession!
    let validResponse = HTTPURLResponse(url: URL(string: "https://something.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    let invalidResponse = HTTPURLResponse(url: URL(string: "https://something.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
    var networkService: RequestHandler!

    override func setUp() {
        super.setUp()
        setupURLProtocolMock()
        networkService = RequestHandler(urlSession: mockSession)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolMock.mockURLs = [:]
    }

    func testThatNetworkServiceCorrectlyHandlesValidResponse() {

        let urlWithValidData = "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Picasso&p=2"
        let validData = JSONDataReader.getDataFromJSONFile(with: "art_objects_list_1")

        URLProtocolMock.mockURLs = [
            URL(string: urlWithValidData): (nil, validData, validResponse)
        ]

        let expectation = XCTestExpectation(description: "Successful JSON to model conversion while loading valid data from API")

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: "Picasso", pageNumber: 2)) { result in
            if case .success = result {
                // No-op. If we reached here, that means we passed the test
            } else {
                XCTFail("Test failed. Expected to get the valid data without any error. Failed due to unexpected result")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testThatNetworkServiceCorrectlyHandlesResponseWithError() {
        let urlWithError = "https://random_error"

        URLProtocolMock.mockURLs = [
            URL(string: urlWithError): (DataLoadError.genericError("Something went wrong"), nil, validResponse)
        ]

        let expectation = XCTestExpectation(description: "Unsuccessful data load operation due to generic error data")

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: "Monet", pageNumber: 1)) { result in
            if case .failure = result {
                // No-op. If we reached here, that means we passed the test
            } else {
                XCTFail("Test failed. Expected to get the DataLoadError with type genericError with error message. Failed due to unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testThatNetworkServiceCorrectlyHandlesResponseWithInvalidResponseCode() {
        let urlWithInvalidResponse = "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Jackson%20Pollock&p=3"
        let invalidResponse = HTTPURLResponse(url: URL(string: "https://github.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        let validData = JSONDataReader.getDataFromJSONFile(with: "art_objects_list_2")

        URLProtocolMock.mockURLs = [
            URL(string: urlWithInvalidResponse): (nil, validData, invalidResponse)
        ]

        let expectation = XCTestExpectation(description: "Unsuccessful data load operation due to invalid response code")

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: "Jackson Pollock", pageNumber: 3)) { result in
            if case .failure(.invalidResponseCode(let code)) = result {
                XCTAssertEqual(code, 400)
            } else {
                XCTFail("Test failed. Expected to get the DataLoadError with type invalidResponseCode with error message. Failed due to unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testThatNetworkServiceCorrectlyHandlesResponseWithEmptyData() {
        let urlWithEmptyData = "https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Picasso&p=2"

        URLProtocolMock.mockURLs = [
            URL(string: urlWithEmptyData): (nil, Data(), validResponse)
        ]

        let expectation = XCTestExpectation(description: "Successful JSON to model conversion while loading valid data from API")

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: "Picasso", pageNumber: 2)) { result in
            if case .failure(.noData) = result {
                // No-op. If we reached here, that means we passed the test
            } else {
                XCTFail("Test failed. Expected to get the DataLoadError with type noData. Failed due to unexpected result")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Private methods

    private func setupURLProtocolMock() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        mockSession = URLSession(configuration: sessionConfiguration)
    }

}

