//
//  AppCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

final class AppCoordinator: Coordinator {

    let window: UIWindow

    var rootViewController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        goToCollectionsListSearchPage()
    }

    //MARK: Private methods
    private func goToCollectionsListSearchPage() {
        let navigationController = UINavigationController()
        self.rootViewController = navigationController

        let collectionsListSearchCoordinator = MuseumCollectionsListSearchCoordinator(navController: navigationController)
        collectionsListSearchCoordinator.start()

        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }
}

