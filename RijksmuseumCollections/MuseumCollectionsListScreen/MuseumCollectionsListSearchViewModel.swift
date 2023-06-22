//
//  MuseumCollectionsListSearchViewModel.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

final class MuseumCollectionsListSearchViewModel {

    private var currentPageNumber = 0
    private var currentSearchKeyword = ""

    private let networkService: RequestHandling

    private var toLoadMoreCollections = true

    @Published var artObjects: [ArtObject] = []
    @Published var errorMessage: String?
    @Published var toShowLoadingIndicator = false

    init(networkService: RequestHandling) {
        self.networkService = networkService
    }

    func searchCollections(with searchText: String) {

        self.toShowLoadingIndicator = true

        currentSearchKeyword = searchText
        currentPageNumber = 0
        self.artObjects.removeAll()

        networkService.request(type: ArtObjectsContainer.self, route: .getCollectionsList(searchKeyword: searchText, pageNumber: currentPageNumber)) { [weak self] result in

            guard let self else { return }

            self.toShowLoadingIndicator = false
            switch result {
            case .success(let artObjectsParentContainer):
                self.artObjects = artObjectsParentContainer.artObjects
            case .failure(let dataLoadError):
                self.errorMessage = dataLoadError.errorMessageString()
            }
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
                    self.artObjects.append(contentsOf: artObjectsParentContainer.artObjects)
                }
            case .failure(let dataLoadError):
                self.errorMessage = dataLoadError.errorMessageString()
            }
        }

    }
}
