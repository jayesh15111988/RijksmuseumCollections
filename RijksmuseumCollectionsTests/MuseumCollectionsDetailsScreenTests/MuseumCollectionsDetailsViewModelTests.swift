//
//  MuseumCollectionsDetailsViewModelTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

@testable import RijksmuseumCollections

final class MuseumCollectionsDetailsViewModelTests: XCTestCase {

    func testThatMuseumCollectionsDetailsViewModelPopulatesProperties() {
        let artObjectViewModel = ArtObjectViewModel(id: "100", title: "Amazing art", longTitle: "Amazing art which was produced in this century and has been top work so far", productionPlacesList: "Amsterdam, Paris, Sydney", webImageURL: "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0", headerImageURL: "https://lh3.googleusercontent.com/FiDD3r3nThrcC6NlXjPNgw5WGoEUr9KVeEfZxZWBMNQlcI4Ds8RhyXHjzGhE4x_JktqD_M_UUcn0Oc7NB2eJL-IrFJLVeKOdIkCIukEl1g=s0", makerName: "Picasso", shortDescription: "This art was created in 2nd century BC")

        let museumCollectionDetailsViewModel = MuseumCollectionsDetailsViewModel(artObjectViewModel: artObjectViewModel)

        XCTAssertEqual(museumCollectionDetailsViewModel.collectionImageURL, "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0")
        XCTAssertEqual(museumCollectionDetailsViewModel.shortTitle, "Amazing art")
        XCTAssertEqual(museumCollectionDetailsViewModel.longTitle, "Amazing art which was produced in this century and has been top work so far")
        XCTAssertEqual(museumCollectionDetailsViewModel.artist, "Artist: Picasso")
        XCTAssertEqual(museumCollectionDetailsViewModel.productionPlaces, "Production Places: Amsterdam, Paris, Sydney")
    }

    func testThatSomeMuseumCollectionsDetailsPropertiesAreInitializedToDefaultValues() {
        let artObjectViewModel = ArtObjectViewModel(id: "100", title: "Amazing art", longTitle: "Amazing art which was produced in this century and has been top work so far", productionPlacesList: "", webImageURL: "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0", headerImageURL: "https://lh3.googleusercontent.com/FiDD3r3nThrcC6NlXjPNgw5WGoEUr9KVeEfZxZWBMNQlcI4Ds8RhyXHjzGhE4x_JktqD_M_UUcn0Oc7NB2eJL-IrFJLVeKOdIkCIukEl1g=s0", makerName: nil, shortDescription: "This art was created in 2nd century BC")

        let museumCollectionDetailsViewModel = MuseumCollectionsDetailsViewModel(artObjectViewModel: artObjectViewModel)

        XCTAssertEqual(museumCollectionDetailsViewModel.collectionImageURL, "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0")
        XCTAssertEqual(museumCollectionDetailsViewModel.shortTitle, "Amazing art")
        XCTAssertEqual(museumCollectionDetailsViewModel.longTitle, "Amazing art which was produced in this century and has been top work so far")
        XCTAssertEqual(museumCollectionDetailsViewModel.artist, "Artist: Unknown Artist")
        XCTAssertEqual(museumCollectionDetailsViewModel.productionPlaces, "Production Places: Unknown Place")
    }
}
