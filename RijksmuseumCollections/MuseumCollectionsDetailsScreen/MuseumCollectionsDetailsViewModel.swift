//
//  MuseumCollectionsDetailsViewModel.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import Foundation

final class MuseumCollectionsDetailsViewModel {

    weak var coordinator: MuseumCollectionsDetailsCoordinator?

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

        collectionImageURL = artObjectViewModel.webImageURL
        shortTitle = artObjectViewModel.title
        longTitle = artObjectViewModel.longTitle
        artist = "Artist: \(artistName)"
        self.productionPlaces = "Production Places: \(productionPlaces)"
    }
}
