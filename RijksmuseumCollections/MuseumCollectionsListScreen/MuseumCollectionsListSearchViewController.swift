//
//  MuseumCollectionsListSearchViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Combine
import UIKit

final class MuseumCollectionsListSearchViewController: UIViewController {

    private let viewModel: MuseumCollectionsListSearchViewModel
    private let alertDisplayUtility: AlertDisplayable

    private let searchBarThrottleInterval = 1.0

    private enum Constants {
        static let emptySearchKeywordStateInfoMessage = "Please start typing keyword in the search box to view the list of collections in Rijksmuseum"

        static let emptyArtObjectsStateInfoMessage = "No art objects found matching current search keyword. Please try searching with another keyword"
    }

    init(alertDisplayUtility: AlertDisplayable, viewModel: MuseumCollectionsListSearchViewModel) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search keyword for collections"
        return searchBar
    }()

    private let userInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let userInfoLabelParentView: UIView = {
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

    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        layoutViews()
        setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        view.backgroundColor = .white
        title = "Rijksmuseum Collection"

        searchBar.delegate = self

        userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage

        view.addSubview(searchBar)
        view.addSubview(userInfoLabelParentView)
        userInfoLabelParentView.addSubview(userInfoLabel)
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
            userInfoLabelParentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInfoLabelParentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userInfoLabelParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Style.Padding.defaultHorizontal),
            userInfoLabelParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Style.Padding.defaultHorizontal)
        ])

        NSLayoutConstraint.activate([
            userInfoLabel.topAnchor.constraint(equalTo: userInfoLabelParentView.topAnchor, constant: Style.Padding.smallVertical),
            userInfoLabel.bottomAnchor.constraint(equalTo: userInfoLabelParentView.bottomAnchor, constant: -Style.Padding.smallVertical),
            userInfoLabel.leadingAnchor.constraint(equalTo: userInfoLabelParentView.leadingAnchor, constant: Style.Padding.smallHorizontal),
            userInfoLabel.trailingAnchor.constraint(equalTo: userInfoLabelParentView.trailingAnchor, constant: -Style.Padding.smallHorizontal),
        ])

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupSubscriptions() {

        viewModel.$artObjects.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] artObjects in
            guard let self else { return }

            self.userInfoLabelParentView.isHidden = !artObjects.isEmpty

            if artObjects.isEmpty {
                self.userInfoLabel.text = Constants.emptyArtObjectsStateInfoMessage
            } else {
                print(artObjects.count)
            }
        }.store(in: &subscriptions)

        viewModel.$errorMessage.receive(on: DispatchQueue.main).compactMap { $0 }.sink { [weak self] errorMessage in
            self?.displayError(with: errorMessage)
        }.store(in: &subscriptions)

        viewModel.$toShowLoadingIndicator.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] toShowLoadingIndicator in

            guard let self else { return }

            if toShowLoadingIndicator {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
        }.store(in: &subscriptions)
    }

    private func displayError(with message: String) {
        self.alertDisplayUtility.showAlert(with: "Error", message: message, actions: [], parentController: self)
    }
}

// MARK: UISearchBarDelegate
extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            self.activityIndicatorView.stopAnimating()
            self.userInfoLabelParentView.isHidden = false
            self.userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage
            return
        }

        // We use this function to throttle trigger of requests since we don't want to fire multiple requests as user types too rapidly
        Timer.scheduledTimer(withTimeInterval: searchBarThrottleInterval, repeats: false) { _ in
            self.userInfoLabelParentView.isHidden = true
            self.userInfoLabel.text = ""
            self.viewModel.searchCollections(with: searchText)
        }
    }
}
