//
//  ArtObjectCollectionViewCell.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

final class ArtObjectCollectionViewCell: UICollectionViewCell {

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }

    private func setupViews() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Style.Padding.smallVertical),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Style.Padding.smallVertical),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ArtObjectViewModel) {
        titleLabel.text = viewModel.title + viewModel.makerName
    }
}

extension ArtObjectCollectionViewCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
