//
//  MuseumCollectionsDetailsScreen.swift
//  RijksmuseumCollectionsUITests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import Foundation

final class MuseumCollectionsDetailsScreen: BaseScreen {
    lazy var navigationTitle = navigationBars["objectsListScreen.navigationBarTitle"]
    lazy var webImageView = images["objectsDetailScreen.webImage"]
    lazy var longTitle = staticTexts["objectsDetailScreen.longTitle"]
    lazy var productionPlaces = staticTexts["objectsDetailScreen.productionPlaces"]
    lazy var artistLabel = staticTexts["objectsDetailScreen.artistLabel"]

    // No actions are needed on this page
}
