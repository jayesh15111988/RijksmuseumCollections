//
//  ArtObjectCollectionViewCell.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

final class ArtObjectCollectionViewCell: UICollectionViewCell {

    var imageDownloader: ImageDownloadable = ImageDownloader.shared

    enum Constants {
        static let imageHeight: CGFloat = 200.0
        static let titleFont = UIFont.systemFont(ofSize: 16)
        static let horizontalDividerHeight: CGFloat = 1.0
    }

    let coverImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.accessibilityIdentifier = "artObjectCell.coverImage"
        return imageView
    }()

    let artObjectTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.titleFont
        label.accessibilityIdentifier = "artObjectCell.artObjectTitle"
        return label
    }()

    private let horizontalDivider: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.accessibilityIdentifier = "artObjectCell.horizontalDivider"
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ArtObjectViewModel) {
        artObjectTitleLabel.text = viewModel.shortDescription
        coverImageView.downloadImage(with: viewModel.headerImageURL, placeholderImage: Images.placeholder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        artObjectTitleLabel.text = nil
    }

    //MARK: Private methods
    private func setupViews() {
        contentView.clipsToBounds = true
        coverImageView.clipsToBounds = true
        contentView.addSubview(coverImageView)
        contentView.addSubview(artObjectTitleLabel)
        contentView.addSubview(horizontalDivider)
    }

    private func layoutViews() {

        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageHeight)
        ])

        NSLayoutConstraint.activate([
            artObjectTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Style.Padding.smallVertical),
            artObjectTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            artObjectTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
            artObjectTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])

        NSLayoutConstraint.activate([
            horizontalDivider.topAnchor.constraint(equalTo: artObjectTitleLabel.bottomAnchor, constant: Style.Padding.smallVertical),
            horizontalDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            horizontalDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
            horizontalDivider.heightAnchor.constraint(equalToConstant: Constants.horizontalDividerHeight),
            horizontalDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Style.Padding.smallVertical)
        ])
    }
}

extension ArtObjectCollectionViewCell: ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
