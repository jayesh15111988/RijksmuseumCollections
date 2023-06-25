//
//  ArtObjectCollectionViewCellTests.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import XCTest

@testable import RijksmuseumCollections

final class ArtObjectCollectionViewCellTests: XCTestCase {

    func testThatArtObjectCollectionViewCellConfiguresItselfBasedOnPassedViewModel() {

        let artObjectViewModel = ArtObjectViewModel(id: "100", title: "Amazing art", longTitle: "Amazing art which was produced in this century and has been top work so far", productionPlacesList: "Amsterdam, Paris, Sydney", webImageURL: "https://lh3.googleusercontent.com/bkaHzbjtQir_Wsp9oM0NHP8OmwRAKvYAVNli_-VuuR01GASOrGObGYGhqh8nejq070zHKeCLGDHRBwdyzdO9kgut_lDUpQG2B23VLONjDw=s0", headerImageURL: "https://lh3.googleusercontent.com/FiDD3r3nThrcC6NlXjPNgw5WGoEUr9KVeEfZxZWBMNQlcI4Ds8RhyXHjzGhE4x_JktqD_M_UUcn0Oc7NB2eJL-IrFJLVeKOdIkCIukEl1g=s0", makerName: "Picasso", shortDescription: "This art was created in 2nd century BC")

        let cell = ArtObjectCollectionViewCell(frame: .zero)
        cell.configure(with: artObjectViewModel)

        XCTAssertEqual(cell.artObjectTitleLabel.text, "This art was created in 2nd century BC", "The title text on ArtObjectCollectionViewCell for given art object view model is incorrect")
        XCTAssertNotNil(cell.coverImageView.image, "The cover image on ArtObjectCollectionViewCell is nil")

        cell.prepareForReuse()
        XCTAssertNil(cell.artObjectTitleLabel.text, "The title label on ArtObjectCollectionViewCell is not nil after preparing cell to reuse")
        XCTAssertNil(cell.coverImageView.image, "The cover image on ArtObjectCollectionViewCell is not nil after preparing cell to reuse")
    }

}
