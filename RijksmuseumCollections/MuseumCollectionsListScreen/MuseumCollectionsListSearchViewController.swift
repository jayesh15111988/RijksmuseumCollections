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

    private lazy var dataSource = setupDatasource()

    private enum Constants {

        static let emptySearchKeywordStateInfoMessage = "Please start typing keyword in the search box to view the list of collections in Rijksmuseum"

        static let emptyArtObjectsStateInfoMessage = "No art objects found matching current search keyword. Please try searching with another keyword"

        static let artObjectImageHeight: CGFloat = 200.0
        static let toolbarHeight: CGFloat = 44.0
    }

    init(alertDisplayUtility: AlertDisplayable = AlertDisplayUtility(), viewModel: MuseumCollectionsListSearchViewModel) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }

    let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.accessibilityIdentifier = "objectsListScreen.searchField"
        searchBar.placeholder = "Search Keyword (Tap search to find)"
        return searchBar
    }()

    let userInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = Constants.emptySearchKeywordStateInfoMessage
        return label
    }()

    let userInfoLabelParentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Style.cornerRadius
        view.backgroundColor = .lightGray
        view.accessibilityIdentifier = "objectsListScreen.informationLabelParentView"
        return view
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
    }()

    lazy var collectionView: UICollectionView = {
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

    //MARK: Private methods
    private func setupViews() {
        navigationController?.navigationBar.accessibilityIdentifier = "objectsListScreen.navigationBarTitle"
        view.backgroundColor = .white
        title = viewModel.title

        updateDisplayState(with: false, message: Constants.emptySearchKeywordStateInfoMessage)

        collectionView.delegate = self
        searchBar.delegate = self

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
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
        userInfoLabelParentView.addSubview(userInfoLabel)
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

        viewModel
            .$loadingState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadingState in

            guard let self else { return }

            switch loadingState {
            case .idle:
                break
            case .loading:
                self.activityIndicatorView.startAnimating()
            case .success(let artObjects):
                guard self.searchBar.text?.isEmpty == false else { return }
                self.updateDisplayState(with: true, message: "")
                self.applySnapshot(with: artObjects)
            case .failure(let errorMessage):
                self.displayError(with: errorMessage)
            case .emptyResult:
                self.updateDisplayState(with: false, message: Constants.emptyArtObjectsStateInfoMessage)
            }

            if loadingState != .loading {
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

        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] action in
            self?.viewModel.retryLastRequest()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

        alertDisplayUtility.showAlert(with: "Error", message: message, actions: [cancelAction, tryAgainAction], parentController: self)
    }

    private func updateDisplayState(with isShowingResultsList: Bool, message: String?) {

        if isShowingResultsList {
            userInfoLabel.text = nil
        } else {
            userInfoLabel.text = message
        }

        userInfoLabelParentView.isHidden = isShowingResultsList
        collectionView.isHidden = !isShowingResultsList
    }

    private func setupDatasource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, artObjectViewModel) ->
                UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ArtObjectCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? ArtObjectCollectionViewCell else {
                    fatalError("Failed to get expected cell type from collection view. Expected ArtObjectCollectionViewCell")
                }
                cell.accessibilityIdentifier = "objectsListScreen.artObjectCell.\(indexPath.row)"
                cell.configure(with: artObjectViewModel)
                return cell
            })
        return dataSource
    }

    private func setupToolbar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: view.frame.width, height: Constants.toolbarHeight))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

        let items = [flexSpace, done]
        doneToolbar.items = items

        searchBar.searchTextField.inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonPressed() {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        searchBar.searchTextField.resignFirstResponder()
    }
}

//MARK: UISearchBarDelegate methods
extension MuseumCollectionsListSearchViewController: UISearchBarDelegate {

    /// A delegate method that gets called after user taps Search button
    /// - Parameter searchBar: An instance of UISearchBar on which this method is called
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        collectionView.setContentOffset(.zero, animated: false)
        dismissKeyboard()
        viewModel.searchCollections(with: searchBar.text)
    }

    /// A delegate method that gets called when text in the UISearchBar changes
    /// - Parameters:
    ///   - searchBar: An instance of UISearchBar on which this method is called
    ///   - searchText: A text typed into UISearchBar field
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            updateDisplayState(with: false, message: Constants.emptySearchKeywordStateInfoMessage)
            viewModel.resetSearchState()
        }
    }
}

extension MuseumCollectionsListSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let artObjectViewModel = dataSource.itemIdentifier(for: indexPath) else {
            fatalError("Can't find the item at \(indexPath.row). Expected valid item at that index path in the collection view")
        }
        viewModel.navigateToDetailsScreen(with: artObjectViewModel)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.toLoadNextPage(currentCellIndex: indexPath.row) {
            viewModel.loadNextPage()
        }
    }
}
