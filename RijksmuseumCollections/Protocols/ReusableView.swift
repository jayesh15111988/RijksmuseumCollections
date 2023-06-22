//
//  ReusableView.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

/// A protocol for reusable views such as Table view cells to provide
/// reuseIdentifier for cell reuse
protocol ReusableView {
    static var reuseIdentifier: String { get }
}

