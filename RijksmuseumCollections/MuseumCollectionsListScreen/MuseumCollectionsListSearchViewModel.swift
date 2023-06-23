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

    private var currentPageNumber = 0
    private var currentSearchKeyword = ""

    private let networkService: RequestHandling

    private var toLoadMoreCollections = true

    @Published var artObjectViewModels: [ArtObjectViewModel] = []
    @Published var errorMessage: String?
    @Published var toShowLoadingIndicator = false

    var coordinator: MuseumCollectionsListSearchCoordinator?

    init(networkService: RequestHandling) {
        self.networkService = networkService
    }

    func searchCollections(with searchText: String?) {

        guard let searchText else { return }

        self.toShowLoadingIndicator = true

        currentSearchKeyword = searchText
        currentPageNumber = 0
        self.artObjectViewModels.removeAll()

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: searchText, pageNumber: currentPageNumber)) { [weak self] result in

            guard let self else { return }

            self.toShowLoadingIndicator = false
            switch result {
            case .success(let artObjectsParentContainer):

                self.populateArtObjectViewModels(with: artObjectsParentContainer.artObjects)

            case .failure(let dataLoadError):
                self.errorMessage = dataLoadError.errorMessageString()
            }
        }
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

        if artObjectViewModels.isEmpty {
            self.artObjectViewModels = artObjectViewModels
        } else {
            self.artObjectViewModels.append(contentsOf: artObjectViewModels)
        }
    }

    func loadNextPage() {

        guard toLoadMoreCollections else {
            return
        }

        self.toShowLoadingIndicator = true
        currentPageNumber += 1

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: currentSearchKeyword, pageNumber: currentPageNumber)) { [weak self] result in

            guard let self else { return }

            self.toShowLoadingIndicator = false

            switch result {
            case .success(let artObjectsParentContainer):

                if artObjectsParentContainer.artObjects.isEmpty {
                    self.toLoadMoreCollections = false
                } else {
                    self.populateArtObjectViewModels(with: artObjectsParentContainer.artObjects)
                }
            case .failure(let dataLoadError):
                self.errorMessage = dataLoadError.errorMessageString()
            }
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
