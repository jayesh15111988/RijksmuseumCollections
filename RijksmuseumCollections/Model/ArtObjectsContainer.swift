//
//  ArtObjectsContainer.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

struct ArtObjectsContainer: Decodable {
    let artObjects: [ArtObject]
}

struct ArtObject: Decodable {
    let id: String
    let title: String
    let longTitle: String
}
