//
//  MuseumCollectionsListSearchScreen.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import Foundation

final class MuseumCollectionsListSearchScreen: BaseScreen {

    private lazy var searchField = searchFields["objectsListScreen.searchField"]
    private lazy var clearTextButton = buttons["Clear text"]
    private lazy var searchButton = buttons["Search"]

    private func tapSearchField() {
        searchField.tap()
    }

    @discardableResult
    func clearSearchField() -> Self {
        clearTextButton.tap()
        return self
    }

    @discardableResult
    func performSearch(with keyword: String) -> Self {
        tapSearchField()
        searchField.typeText(keyword)
        searchButton.tap()
        return self
    }

    func tapCell(with identifier: String) {
        cell(with: identifier).tap()
    }
}
