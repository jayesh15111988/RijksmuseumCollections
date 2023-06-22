//
//  MuseumCollectionsListSearchViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

final class MuseumCollectionsListSearchViewController: UIViewController {

    private let viewModel: MuseumCollectionsListSearchViewModel

    init(viewModel: MuseumCollectionsListSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search keyword for collections"
        return searchBar
    }()

    private let emptySearchInputLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Please start typing keyword in the search box to view the list of collections in Rijksmuseum"
        return label
    }()

    private let emptySearchInputLabelParentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Style.cornerRadius
        view.backgroundColor = .lightGray
        return view
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        view.backgroundColor = .white
        title = "Rijksmuseum Collection"

        searchBar.delegate = self

        view.addSubview(searchBar)
        view.addSubview(emptySearchInputLabelParentView)
        emptySearchInputLabelParentView.addSubview(emptySearchInputLabel)
        view.addSubview(activityIndicatorView)
    }

    private func layoutViews() {

        // Constraints for searchBar
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            emptySearchInputLabelParentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchInputLabelParentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptySearchInputLabelParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Style.Padding.defaultHorizontal),
            emptySearchInputLabelParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Style.Padding.defaultHorizontal)
        ])

        NSLayoutConstraint.activate([
            emptySearchInputLabel.topAnchor.constraint(equalTo: emptySearchInputLabelParentView.topAnchor, constant: Style.Padding.smallVertical),
            emptySearchInputLabel.bottomAnchor.constraint(equalTo: emptySearchInputLabelParentView.bottomAnchor, constant: -Style.Padding.smallVertical),
            emptySearchInputLabel.leadingAnchor.constraint(equalTo: emptySearchInputLabelParentView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            emptySearchInputLabel.trailingAnchor.constraint(equalTo: emptySearchInputLabelParentView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
        ])

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: UISearchBarDelegate
extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // We use this function to throttle trigger of requests since we don't want to fire multiple requests as user types too rapidly
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchText.isEmpty {
                self.emptySearchInputLabelParentView.isHidden = false
                self.activityIndicatorView.stopAnimating()
            } else {
                self.emptySearchInputLabelParentView.isHidden = true
                self.viewModel.searchCollections(with: searchText)
                self.activityIndicatorView.startAnimating()
            }
        }
    }
}
