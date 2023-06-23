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
        searchBar.placeholder = "Search Keyword (Tap search to find)"
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
        setupToolbar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        view.backgroundColor = .white
        title = "Rijksmuseum Collection"

        updateDisplayState(with: false)

        collectionView.delegate = self
        searchBar.delegate = self

        userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage

        registerViews()

        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ArtObjectCollectionViewSectionHeaderView.reuseIdentifier, for: indexPath) as? ArtObjectCollectionViewSectionHeaderView {
                headerView.configure(with: "Collection Items")
                return headerView
            }
            return nil
        }

        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()

        view.addSubview(searchBar)
        view.addSubview(userInfoLabelParentView)
        userInfoLabelParentView.addSubview(userInfoLabel)
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))

            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)), subitems: [item])

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(30))

            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            header.pinToVisibleBounds = true

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]

            return section
        }
        return layout
    }

    private func registerViews() {
        collectionView.register(ArtObjectCollectionViewCell.self, forCellWithReuseIdentifier: ArtObjectCollectionViewCell.reuseIdentifier)
        collectionView.register(ArtObjectCollectionViewSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ArtObjectCollectionViewSectionHeaderView.reuseIdentifier)
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

            guard self.searchBar.text?.isEmpty == false else { return }

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
        dataSource.apply(snapshot, animatingDifferences: false)
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

    private func setupToolbar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

        let items = [flexSpace, done]
        doneToolbar.items = items

        self.searchBar.searchTextField.inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonPressed() {
        self.searchBar.searchTextField.resignFirstResponder()
    }
}

extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.searchTextField.resignFirstResponder()
        self.viewModel.searchCollections(with: searchBar.text)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            updateDisplayState(with: false)
            userInfoLabel.text = Constants.emptySearchKeywordStateInfoMessage
        }
    }
}

extension MuseumCollectionsListSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let artObjectViewModel = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.navigateToDetailsScreen(with: artObjectViewModel)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.toLoadNextPage(currentCellIndex: indexPath.row) {
            viewModel.loadNextPage()
        }
        print("Current index path \(indexPath.row)")
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
