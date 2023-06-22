//
//  MuseumCollectionsListSearchViewController.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Combine
import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<MuseumCollectionsListSearchViewController.Section, ArtObjectViewModel>

typealias Snapshot = NSDiffableDataSourceSnapshot<MuseumCollectionsListSearchViewController.Section, ArtObjectViewModel>

final class MuseumCollectionsListSearchViewController: UIViewController {

    private let viewModel: MuseumCollectionsListSearchViewModel
    private let alertDisplayUtility: AlertDisplayable

    private let searchBarThrottleInterval = 1.0

    private lazy var dataSource = setupDatasource()

    private enum Constants {
        static let emptySearchKeywordStateInfoMessage = "Please start typing keyword in the search box to view the list of collections in Rijksmuseum"

        static let emptyArtObjectsStateInfoMessage = "No art objects found matching current search keyword. Please try searching with another keyword"

        static let fixedArtObjectImageHeight: CGFloat = 200.0
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
        label.text = Constants.emptySearchKeywordStateInfoMessage
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

    private lazy var collectionView: UICollectionView = {
        let viewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    enum Section {
        case artObject
    }

    private var subscriptions: Set<AnyCancellable> = []

    var snapshot: Snapshot?

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

        updateDisplayState(with: false)

        searchBar.delegate = self
        collectionView.delegate = self

        userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage

        collectionView.register(ArtObjectCollectionViewCell.self, forCellWithReuseIdentifier: ArtObjectCollectionViewCell.reuseIdentifier)

        collectionView.dataSource = dataSource

        view.addSubview(searchBar)
        view.addSubview(userInfoLabelParentView)
        userInfoLabelParentView.addSubview(userInfoLabel)
        view.addSubview(activityIndicatorView)
        view.addSubview(collectionView)
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

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupSubscriptions() {

        viewModel.$artObjectViewModels.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] artObjects in
            guard let self else { return }

            self.updateDisplayState(with: !artObjects.isEmpty)

            if artObjects.isEmpty {
                self.userInfoLabel.text = Constants.emptyArtObjectsStateInfoMessage
            } else {
                self.applySnapshot(with: artObjects)
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

    private func applySnapshot(with viewModels: [ArtObjectViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.artObject])
        snapshot.appendItems(viewModels, toSection: .artObject)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func displayError(with message: String) {
        self.alertDisplayUtility.showAlert(with: "Error", message: message, actions: [], parentController: self)
    }

    private func updateDisplayState(with isShowingResultsList: Bool) {
        self.userInfoLabelParentView.isHidden = isShowingResultsList
        self.collectionView.isHidden = !isShowingResultsList
    }

    private func setupDatasource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, artObjectViewModel) ->
                UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ArtObjectCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? ArtObjectCollectionViewCell else {
                    //TODO: Add error handling due to nil cell
                    return nil
                }
                cell.configure(with: artObjectViewModel)
                return cell
            })
        return dataSource
    }
}

// MARK: UISearchBarDelegate
extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            self.activityIndicatorView.stopAnimating()
            updateDisplayState(with: false)
            self.userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage
            return
        }

        // We use this function to throttle trigger of requests since we don't want to fire multiple requests as user types too rapidly
        Timer.scheduledTimer(withTimeInterval: searchBarThrottleInterval, repeats: false) { _ in
            self.updateDisplayState(with: true)
            self.userInfoLabel.text = ""
            self.viewModel.searchCollections(with: searchText)
        }
    }
}

extension MuseumCollectionsListSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let artObjectViewModel = dataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }

        let itemHeight = itemHeight(for: view.frame.width, artObjectViewModel: artObjectViewModel)

        return CGSize(width: view.frame.width - 2 * Style.Padding.smallHorizontal, height: itemHeight)
    }

    func itemHeight(for width: CGFloat, artObjectViewModel: ArtObjectViewModel) -> CGFloat {

        let totalPadding = 3 * Style.Padding.smallVertical

        return ceil(Constants.fixedArtObjectImageHeight + artObjectViewModel.shortDescription.height(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 16.0)) + totalPadding)
    }
}

extension MuseumCollectionsListSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let artObjectViewModel = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        print(artObjectViewModel.shortDescription)
    }
}

//Taken from: https://stackoverflow.com/questions/30450434/figure-out-size-of-uilabel-based-on-string-in-swift

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintInRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let boundingBox = self.boundingRect(with: constraintInRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
