//
//  MuseumCollectionsListSearchViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

final class MuseumCollectionsListSearchViewController: UIViewController {

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
        view.backgroundColor = .white
        title = "Rijksmuseum Collection"

        searchBar.delegate = self

        view.addSubview(searchBar)
        view.addSubview(emptySearchInputLabelParentView)
        emptySearchInputLabelParentView.addSubview(emptySearchInputLabel)
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
    }
}

// MARK: UISearchBarDelegate
extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // We use this function to throttle trigger of requests since we don't want to fire multiple requests as user types too rapidly
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            print(searchText)
            if searchText.isEmpty {
                self.emptySearchInputLabelParentView.isHidden = false
            } else {
                self.emptySearchInputLabelParentView.isHidden = true
            }
        }
    }
}
