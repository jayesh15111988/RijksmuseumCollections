//
//  MuseumCollectionsDetailsViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

final class MuseumCollectionsDetailsViewController: UIViewController {

    private let viewModel: MuseumCollectionsDetailsViewModel

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
    }

    private func setupViews() {

        self.title = viewModel.shortTitle
        self.view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        for i in 0..<10 {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = "Line 1 ds d asd as das d s sdf sd fsd fsd fsd f sdf sdf sdf sd fsd fs df sd fsd fsd f\(i)\nLine 2\(i)\nLine 3\(i)"
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            stackView.addArrangedSubview(label)
            //label.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }
    }

    init(viewModel: MuseumCollectionsDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
