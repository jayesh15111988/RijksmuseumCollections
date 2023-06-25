//
//  Coordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

// A protocol to manage routing and navigation between screens
protocol Coordinator: AnyObject {
    var rootViewController: UINavigationController { get }

    func start()
}

