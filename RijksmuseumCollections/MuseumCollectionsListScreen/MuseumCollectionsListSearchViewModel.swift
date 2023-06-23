//
//  MuseumCollectionsListSearchViewModel.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

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
    private var currentPageNumber = 1
    private var currentSearchKeyword = ""
    private var totalNumberOfObjects = 0

    private let networkService: RequestHandling

    private var toLoadMoreCollections = true

    @Published var loadingState: LoadingState = .idle

    var coordinator: MuseumCollectionsListSearchCoordinator?

    let title: String

    init(networkService: RequestHandling) {
        self.networkService = networkService
        self.title = "Rijksmuseum Collection"
    }

    func searchCollections(with searchText: String?) {

        guard let searchText else { return }

        self.loadingState = .loading

        resetPreviousSearchState()
        currentSearchKeyword = searchText

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: searchText, pageNumber: currentPageNumber)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let artObjectsParentContainer):

                guard artObjectsParentContainer.count != 0 else {
                    self.loadingState = .emptyResult
                    self.loadingState = .idle
                    return
                }

                self.totalNumberOfObjects = artObjectsParentContainer.count
                self.populateArtObjectViewModels(with: artObjectsParentContainer.artObjects)

            case .failure(let dataLoadError):
                self.loadingState = .failure(errorMessage: dataLoadError.errorMessageString())
            }
            self.loadingState = .idle
        }
    }

    private func resetPreviousSearchState() {
        currentPageNumber = 1
        toLoadMoreCollections = true
        totalNumberOfObjects = 0
        artObjectViewModels.removeAll()
    }

    private func populateArtObjectViewModels(with artObjects: [ArtObjectsContainer.ArtObject]) {

        let artObjectViewModels = artObjects.map { artObject -> ArtObjectViewModel in

            let shortDescription: String

            if let artMaker = artObject.principalOrFirstMaker {
                shortDescription = "\(artObject.title) By \(artMaker)"
            } else {
                shortDescription = "\(artObject.title)"
            }

            return ArtObjectViewModel(id: artObject.id, title: artObject.title, longTitle: artObject.longTitle, productionPlacesList: artObject.productionPlaces.joined(separator: ", "), webImageURL: artObject.webImage?.url, headerImageURL: artObject.headerImage?.url, makerName: artObject.principalOrFirstMaker, shortDescription: shortDescription) }

        if self.artObjectViewModels.isEmpty {
            self.artObjectViewModels = artObjectViewModels
        } else {
            self.artObjectViewModels.append(contentsOf: artObjectViewModels)
        }
        self.loadingState = .success(viewModels: self.artObjectViewModels)

        if artObjectViewModels.count == totalNumberOfObjects {
            toLoadMoreCollections = false
        }
    }

    func toLoadNextPage(currentCellIndex: Int) -> Bool {
        return currentCellIndex == artObjectViewModels.count - Constants.listOffsetToStartLoadingNextBatch
    }

    func loadNextPage() {
        guard toLoadMoreCollections else {
            return
        }

        self.loadingState = .loading
        currentPageNumber += 1

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: currentSearchKeyword, pageNumber: currentPageNumber)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let artObjectsParentContainer):
                self.populateArtObjectViewModels(with: artObjectsParentContainer.artObjects)
            case .failure(let dataLoadError):
                self.loadingState = .failure(errorMessage: dataLoadError.errorMessageString())
            }
            self.loadingState = .idle
        }
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
