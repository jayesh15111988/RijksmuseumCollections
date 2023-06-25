//
//  MuseumCollectionsDetailsCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

// A coordinator for managing screen for MuseumCollectionsDetailsViewController controller
final class MuseumCollectionsDetailsCoordinator: Coordinator {

    var rootViewController: UINavigationController
    private let viewModel: ArtObjectViewModel

    init(navController: UINavigationController, viewModel: ArtObjectViewModel) {
        self.rootViewController = navController
        self.viewModel = viewModel
    }

    func start() {

        let collectionDetailsViewModel = MuseumCollectionsDetailsViewModel(artObjectViewModel: viewModel)
        let collectionDetailsViewController = MuseumCollectionsDetailsViewController(viewModel: collectionDetailsViewModel)

        collectionDetailsViewModel.coordinator = self

        self.rootViewController.pushViewController(collectionDetailsViewController, animated: true)
    }
}


