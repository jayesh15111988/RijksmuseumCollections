//
//  MuseumCollectionsListSearchViewModel.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

typealias LoadingState = MuseumCollectionsListSearchViewModel.LoadingState

struct ArtObjectViewModel {
    let id: String
    let title: String
    let longTitle: String
    let productionPlacesList: String
    let webImageURL: String?
    let headerImageURL: String?
    let makerName: String?
    let shortDescription: String
}

final class MuseumCollectionsListSearchViewModel {

    // An enum to encode current app state
    enum LoadingState {
        case idle
        case loading
        case success(viewModels: [ArtObjectViewModel])
        case failure(errorMessage: String)
        case emptyResult
    }

    enum Constants {
        static let listOffsetToStartLoadingNextBatch = 5
    }

    var artObjectViewModels: [ArtObjectViewModel] = []
    var currentSearchKeyword = ""

    // Pagination starts from page #1. Page #0 and #1 are the same
    var currentPageNumber = 1
    var totalNumberOfObjects = 0

    var toLoadMoreCollections = true

    @Published var loadingState: LoadingState = .idle

    var coordinator: MuseumCollectionsListSearchCoordinator?

    private let networkService: RequestHandling
    private let imageDownloader: ImageDownloadable
    let title: String

    init(networkService: RequestHandling, imageDownloader: ImageDownloadable = ImageDownloader.shared) {
        self.networkService = networkService
        self.imageDownloader = imageDownloader
        title = "Rijksmuseum Collection"
    }

    /// A method to trigger searching art objects for input search text
    /// - Parameter searchText: A search keyword entered by user in the search field
    func searchCollections(with searchText: String?) {

        // If the search text is nil or empty, simply return.
        // This will keep the app state unchanged
        guard let searchText, !searchText.isEmpty else {
            return
        }

        // Do not trigger request if the loadingState is already running
        guard loadingState != .loading else {
            return
        }

        resetSearchState()

        currentSearchKeyword = searchText

        loadItems(with: searchText, pageNumber: currentPageNumber)
    }

    /// A method to retry last request if that request previously failed
    func retryLastRequest() {
        loadItems(with: currentSearchKeyword, pageNumber: currentPageNumber)
    }

    /// Reset search state at the beginning of each keyword search
    func resetSearchState() {
        currentPageNumber = 1
        toLoadMoreCollections = true
        totalNumberOfObjects = 0
        artObjectViewModels.removeAll()
        imageDownloader.clearCache()
        loadingState = .idle
    }

    //MARK: Private methods

    /// A method to load items for given keyword and page number
    /// - Parameters:
    ///   - searchText: A keyword on which to perform search
    ///   - pageNumber: A page number for the request
    private func loadItems(with searchText: String, pageNumber: Int) {
        loadingState = .loading
        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: searchText, pageNumber: pageNumber)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let artObjectsParentContainer):
                // If loading for the first page, set these variables in the beginning
                if pageNumber == 1 {
                    guard artObjectsParentContainer.count != 0 else {
                        self.loadingState = .emptyResult
                        return
                    }

                    self.totalNumberOfObjects = artObjectsParentContainer.count
                }

                self.populateArtObjectViewModels(with: artObjectsParentContainer.artObjects)

            case .failure(let dataLoadError):
                self.loadingState = .failure(errorMessage: dataLoadError.errorMessageString())
            }
        }
    }

    /// A method to convert objects of type ArtObjectsContainer.ArtObject into successful
    /// loading state and inform view controller of successful load
    /// - Parameter artObjects: An array of ArtObject instances
    private func populateArtObjectViewModels(with artObjects: [ArtObjectsContainer.ArtObject]) {

        let localArtObjectViewModels = artObjects.map { artObject -> ArtObjectViewModel in

            let shortDescription: String

            if let artMaker = artObject.principalOrFirstMaker {
                shortDescription = "\(artObject.title) By \(artMaker)"
            } else {
                shortDescription = "\(artObject.title)"
            }

            return ArtObjectViewModel(id: artObject.id, title: artObject.title, longTitle: artObject.longTitle, productionPlacesList: artObject.productionPlaces.joined(separator: ", "), webImageURL: artObject.webImage?.url, headerImageURL: artObject.headerImage?.url, makerName: artObject.principalOrFirstMaker, shortDescription: shortDescription) }

        if artObjectViewModels.isEmpty {
            artObjectViewModels = localArtObjectViewModels
        } else {
            artObjectViewModels.append(contentsOf: localArtObjectViewModels)
        }
        loadingState = .success(viewModels: artObjectViewModels)

        toLoadMoreCollections = artObjectViewModels.count < totalNumberOfObjects
    }

    /// A method to decide whether to load next page or not depending on current cell index
    /// - Parameter currentCellIndex: An index of current cell that is about to get displayed
    /// - Returns: A boolean flag indicating whether to load next batch of art objects
    func toLoadNextPage(currentCellIndex: Int) -> Bool {
        return currentCellIndex == artObjectViewModels.count - Constants.listOffsetToStartLoadingNextBatch
    }

    /// A method to load next batch of results if there are still results to fetch
    func loadNextPage() {
        // Return early if all the objects for given search keyword have already been loaded
        guard toLoadMoreCollections else {
            return
        }

        guard loadingState != .loading else {
            return
        }

        currentPageNumber += 1

        loadItems(with: currentSearchKeyword, pageNumber: currentPageNumber)
    }

    /// A method to navigate to details page with selected ArtObjectViewModel instance
    /// - Parameter viewModel: A viewModel for selected art object
    func navigateToDetailsScreen(with viewModel: ArtObjectViewModel) {
        coordinator?.navigateToDetailsScreen(with: viewModel)
    }
}

extension ArtObjectViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: ArtObjectViewModel, rhs: ArtObjectViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension LoadingState: Equatable {
    static func ==(lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.emptyResult, .emptyResult):
            return true
        case (let .success(lhsViewModels), let .success(rhsViewModels)):
            return lhsViewModels == rhsViewModels
        case (let .failure(lhsMessage), let .failure(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
