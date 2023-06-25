//
//  MuseumCollectionsListSearchCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

// A coordinator for managing screen for MuseumCollectionsListSearch controller
final class MuseumCollectionsListSearchCoordinator: Coordinator {

    var rootViewController: UINavigationController

    init(navController: UINavigationController) {
        self.rootViewController = navController
    }

    func start() {
        let collectionsListSearchViewModel = MuseumCollectionsListSearchViewModel(networkService: RequestHandler())
        let collectionsListSearchViewController = MuseumCollectionsListSearchViewController(alertDisplayUtility: AlertDisplayUtility(), viewModel: collectionsListSearchViewModel)

        collectionsListSearchViewModel.coordinator = self

        self.rootViewController.pushViewController(collectionsListSearchViewController, animated: true)
    }

    func navigateToDetailsScreen(with viewModel: ArtObjectViewModel) {
        let collectionsDetailsCoordinator = MuseumCollectionsDetailsCoordinator(navController: self.rootViewController, viewModel: viewModel)
        collectionsDetailsCoordinator.start()
    }
}

