//
//  MockAlertDisplayUtility.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/24/23.
//

import UIKit

@testable import RijksmuseumCollections

final class MockAlertDisplayUtility: AlertDisplayable {

    var shownTitle = ""
    var shownMessage = ""

    func showAlert(with title: String, message: String, actions: [UIAlertAction], parentController: UIViewController) {
        self.shownTitle = title
        self.shownMessage = message
    }
}
