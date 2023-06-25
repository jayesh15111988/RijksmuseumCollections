//
//  ArtObjectCollectionViewSectionHeaderView.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

/// A header for each collection view section section
final class ArtObjectCollectionViewSectionHeaderView: UICollectionReusableView {

    let topTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        addSubview(topTitleLabel)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            topTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.Padding.smallHorizontal),
            topTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Style.Padding.smallHorizontal),
            topTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Style.Padding.smallVertical),
            topTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Style.Padding.smallVertical)
        ])
    }

    func configure(with title: String) {
        topTitleLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        topTitleLabel.text = nil
    }
}

extension ArtObjectCollectionViewSectionHeaderView: ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
