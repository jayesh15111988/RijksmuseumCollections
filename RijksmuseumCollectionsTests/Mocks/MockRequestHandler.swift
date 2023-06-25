//
//  MockRequestHandler.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import Foundation

@testable import RijksmuseumCollections

class MockRequestHandler: RequestHandling {

    var toFail = false
    var toSendEmptyResponse = false

    var lastRequestedURL: String?

    func request<T>(type: T.Type, route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) where T : Decodable {

        lastRequestedURL = route.asRequest().url?.absoluteString

        if toFail {
            completion(.failure(DataLoadError.genericError("Something went wrong while loading a request")))
            return
        }

        if toSendEmptyResponse {
            let emptyArtObjectsList: T? = JSONDataReader.getModelFromJSONFile(with: "art_objects_empty_list")
            completion(.success(emptyArtObjectsList!))
            return
        }

        switch route {
        case .getCollectionsList(_, let pageNumber):
            let artObjectsList: T? = JSONDataReader.getModelFromJSONFile(with: "art_objects_list_\(pageNumber)")
            completion(.success(artObjectsList!))
        }
    }
}

