//
//  MuseumCollectionsListSearchViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

final class MuseumCollectionsListSearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        layoutViews()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.view.backgroundColor = .white
    }

    private func layoutViews() {

    }
}
