//
//  MuseumCollectionsDetailsViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/23/23.
//

import UIKit

final class MuseumCollectionsDetailsViewController: UIViewController {

    private let viewModel: MuseumCollectionsDetailsViewModel
    private let imageDownloader: ImageDownloadable

    private enum Constants {
        static let imageHeight: CGFloat = 300
        static let stackViewVerticalSpacing: CGFloat = 10
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewVerticalSpacing
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let artObjectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "objectsDetailScreen.webImage"
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
        configureViews(with: self.viewModel)
    }

    func configureViews(with viewModel: MuseumCollectionsDetailsViewModel) {
        let longTitleLabel = getLabelWith(text: viewModel.longTitle)
        let productionPlacesLabel = getLabelWith(text: viewModel.productionPlaces)
        let artistLabel = getLabelWith(text: viewModel.artist)

        longTitleLabel.accessibilityIdentifier = "objectsDetailScreen.longTitle"
        productionPlacesLabel.accessibilityIdentifier = "objectsDetailScreen.productionPlaces"
        artistLabel.accessibilityIdentifier = "objectsDetailScreen.artistLabel"

        stackView.addArrangedSubview(longTitleLabel)
        stackView.addArrangedSubview(artObjectImageView)
        stackView.addArrangedSubview(artistLabel)
        stackView.addArrangedSubview(productionPlacesLabel)

        NSLayoutConstraint.activate([
            artObjectImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight)
        ])

        NSLayoutConstraint.activate([
            longTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])

        NSLayoutConstraint.activate([
            productionPlacesLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])

        NSLayoutConstraint.activate([
            artistLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])

        self.artObjectImageView.downloadImage(with: viewModel.collectionImageURL, placeholderImage: Images.placeholder)
    }

    init(viewModel: MuseumCollectionsDetailsViewModel, imageDownloader: ImageDownloadable = ImageDownloader.shared) {
        self.viewModel = viewModel
        self.imageDownloader = imageDownloader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Private methods
    private func setupViews() {
        title = viewModel.shortTitle
        view.backgroundColor = .white
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
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    /// A method to get label with provided text on it
    /// - Parameter text: A text to display on UILabel instance
    /// - Returns: An UILabel instance with passed text set on it
    private func getLabelWith(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = text
        return label
    }
}
