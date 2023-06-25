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

    var currentPageNumber = 1
    var totalNumberOfObjects = 0

    private let networkService: RequestHandling

    var toLoadMoreCollections = true

    @Published var loadingState: LoadingState = .idle

    var coordinator: MuseumCollectionsListSearchCoordinator?

    let imageDownloader: ImageDownloadable

    let title: String

    init(networkService: RequestHandling, imageDownloader: ImageDownloadable = ImageDownloader.shared) {
        self.networkService = networkService
        self.title = "Rijksmuseum Collection"
        self.imageDownloader = imageDownloader
    }

    func searchCollections(with searchText: String?) {

        guard let searchText else {
            return
        }

        guard loadingState != .loading else {
            return
        }

        resetSearchState()

        self.loadingState = .loading
        currentSearchKeyword = searchText

        loadItems(with: searchText, pageNumber: currentPageNumber)
    }

    private func loadItems(with searchText: String, pageNumber: Int) {
        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: searchText, pageNumber: pageNumber)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let artObjectsParentContainer):

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

    func retryLastRequest() {
        loadItems(with: currentSearchKeyword, pageNumber: currentPageNumber)
    }

    func resetSearchState() {
        currentPageNumber = 1
        toLoadMoreCollections = true
        totalNumberOfObjects = 0
        artObjectViewModels.removeAll()
        imageDownloader.clearCache()
        loadingState = .idle
    }

    private func populateArtObjectViewModels(with artObjects: [ArtObjectsContainer.ArtObject]) {

        let localArtObjectViewModels = artObjects.map { artObject -> ArtObjectViewModel in

            let shortDescription: String

            if let artMaker = artObject.principalOrFirstMaker {
                shortDescription = "\(artObject.title) By \(artMaker)"
            } else {
                shortDescription = "\(artObject.title)"
            }

            return ArtObjectViewModel(id: artObject.id, title: artObject.title, longTitle: artObject.longTitle, productionPlacesList: artObject.productionPlaces.joined(separator: ", "), webImageURL: artObject.webImage?.url, headerImageURL: artObject.headerImage?.url, makerName: artObject.principalOrFirstMaker, shortDescription: shortDescription) }

        if self.artObjectViewModels.isEmpty {
            self.artObjectViewModels = localArtObjectViewModels
        } else {
            self.artObjectViewModels.append(contentsOf: localArtObjectViewModels)
        }
        self.loadingState = .success(viewModels: self.artObjectViewModels)

        toLoadMoreCollections = self.artObjectViewModels.count < totalNumberOfObjects
    }

    func toLoadNextPage(currentCellIndex: Int) -> Bool {
        return currentCellIndex == artObjectViewModels.count - Constants.listOffsetToStartLoadingNextBatch
    }

    func loadNextPage() {
        guard toLoadMoreCollections else {
            return
        }

        guard loadingState != .loading else {
            return
        }

        self.loadingState = .loading
        currentPageNumber += 1

        loadItems(with: currentSearchKeyword, pageNumber: currentPageNumber)
    }

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
