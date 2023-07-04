//
//  AppCoordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

// A coordinator to manage navigation and setting up the view controller
// stack when app starts the first time
final class AppCoordinator: Coordinator {

    private let window: UIWindow
    var rootViewController: UINavigationController

    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
    }

    func start() {
        goToCollectionsListSearchPage()
    }

    //MARK: Private methods
    private func goToCollectionsListSearchPage() {

        let collectionsListSearchCoordinator = MuseumCollectionsListSearchCoordinator(navController: rootViewController)
        collectionsListSearchCoordinator.start()

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}

