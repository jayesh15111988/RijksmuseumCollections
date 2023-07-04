//
//  APIRoute.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

/// An enum to encode all the operations associated with specific endpoint
enum APIRoute {

    case getCollectionsList(searchKeyword: String, pageNumber: Int)

    // Base URL on which all the URL requests are based
    private var baseURLString: String { "https://www.rijksmuseum.nl/api/" }

    private var defaultCulture: String { "nl" }

    // API secret key to get server data
    private var key: String { "0fiuZFh4" }

    private var url: URL? {
        switch self {
        case .getCollectionsList:
            return URL(string: baseURLString + defaultCulture + "/collection")
        }
    }

    private var parameters: [URLQueryItem] {
        switch self {
        case .getCollectionsList(let searchKeyword, let pageNumber):
            return [
                URLQueryItem(name: "key", value: key),
                URLQueryItem(name: "q", value: searchKeyword),
                URLQueryItem(name: "p", value: String(pageNumber))
            ]
        }
    }

    /// A method to convert given APIRoute case into URLRequest object
    /// - Returns: An instance of URLRequest
    func asRequest() -> URLRequest {
        guard let url = url else {
            preconditionFailure("Missing URL for route: \(self)")
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if !parameters.isEmpty {
            components?.queryItems = parameters
        }

        guard let parametrizedURL = components?.url else {
            preconditionFailure("Missing URL with parameters for url: \(url)")
        }

        return URLRequest(url: parametrizedURL)
    }
}

