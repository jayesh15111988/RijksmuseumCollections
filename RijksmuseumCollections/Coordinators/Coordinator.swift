//
//  Coordinator.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

protocol Coordinator: AnyObject {
    var rootViewController: UINavigationController { get }

    func start()
}

