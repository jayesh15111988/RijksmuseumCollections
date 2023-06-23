//
//  MuseumCollectionsDetailsViewModel.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import Foundation

final class MuseumCollectionsDetailsViewModel {

    var coordinator: MuseumCollectionsDetailsCoordinator?

    let collectionImageURL: String?
    let shortTitle: String
    let longTitle: String
    let artist: String
    let productionPlaces: String

    init(artObjectViewModel: ArtObjectViewModel) {
        let productionPlaces = artObjectViewModel.productionPlacesList.isEmpty ? "Unknown Place" : artObjectViewModel.productionPlacesList

        let artistName: String

        if let artist = artObjectViewModel.makerName {
            artistName = artist
        } else {
            artistName = "Unknown Artist"
        }

        self.collectionImageURL = artObjectViewModel.webImageURL
        self.shortTitle = artObjectViewModel.title
        self.longTitle = artObjectViewModel.longTitle
        self.artist = "Artist: \(artistName)"
        self.productionPlaces = "Production Places: \(productionPlaces)"
    }
}
