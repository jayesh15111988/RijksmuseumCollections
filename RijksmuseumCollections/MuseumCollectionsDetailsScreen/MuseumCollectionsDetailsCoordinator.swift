//
//  MuseumCollectionsDetailsCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

final class MuseumCollectionsDetailsCoordinator: Coordinator {

    var rootViewController: UINavigationController
    let viewModel: ArtObjectViewModel

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


