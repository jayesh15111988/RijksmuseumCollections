//
//  ArtObjectsContainer.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

/// A Decodable struct to encode art objects info downloaded from endpoint
struct ArtObjectsContainer: Decodable {
    let artObjects: [ArtObject]
    let count: Int

    struct ArtObject: Decodable {
        let id: String
        let title: String
        let longTitle: String
        let productionPlaces: [String]
        let webImage: WebImage?
        let headerImage: HeaderImage?
        let principalOrFirstMaker: String?

        struct WebImage: Decodable {
            let url: String?
        }

        struct HeaderImage: Decodable {
            let url: String?
        }
    }

}
