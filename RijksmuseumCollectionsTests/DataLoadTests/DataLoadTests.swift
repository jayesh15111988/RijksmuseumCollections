//
//  DataLoadTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

@testable import RijksmuseumCollections

final class DataLoadErrorTests: XCTestCase {

    func testThatDataLoadErrorEnumReturnsCorrectErrorDescription() {

        XCTAssertEqual(DataLoadError.badURL.errorMessageString(), "Invalid URL encountered. Please enter the valid URL and try again", "Error message string for badURL data load error is incorrect")

        XCTAssertEqual(DataLoadError.genericError("Something went wrong").errorMessageString(), "Something went wrong", "Error message string for genericError data load error is incorrect")

        XCTAssertEqual(DataLoadError.noData.errorMessageString(), "No data received from the server. Please try again later", "Error message string for noData data load error is incorrect")

        XCTAssertEqual(DataLoadError.malformedContent.errorMessageString(), "Received malformed content. Error may have been logged on the server to investigate further", "Error message string for malformedContent data load error is incorrect")

        XCTAssertEqual(DataLoadError.invalidResponseCode(400).errorMessageString(), "Server returned invalid response code. Expected between the range 200-299. Server returned 400", "Error message string for invalidResponseCode data load error is incorrect")

        XCTAssertEqual(DataLoadError.decodingError("Key image_data not found").errorMessageString(), "Key image_data not found", "Error message string for decodingError data load error is incorrect")

    }
}
