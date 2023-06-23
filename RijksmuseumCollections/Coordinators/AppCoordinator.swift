//
//  AppCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

final class AppCoordinator: Coordinator {

    let window: UIWindow

    var rootViewController: UINavigationController

    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
    }

    func start() {
        goToCollectionsListSearchPage()
    }

    //MARK: Private methods
    private func goToCollectionsListSearchPage() {

        let collectionsListSearchCoordinator = MuseumCollectionsListSearchCoordinator(navController: rootViewController)
        collectionsListSearchCoordinator.start()

        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
}

