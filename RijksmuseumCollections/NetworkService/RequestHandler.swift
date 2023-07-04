//
//  RequestHandler.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

/// An enum to encode all the data load error conditions
enum DataLoadError: Error {
    case badURL
    case genericError(String)
    case noData
    case malformedContent
    case invalidResponseCode(Int)
    case decodingError(String)

    func errorMessageString() -> String {
        switch self {
        case .badURL:
            return "Invalid URL encountered. Please enter the valid URL and try again"
        case let .genericError(message):
            return message
        case .noData:
            return "No data received from the server. Please try again later"
        case .malformedContent:
            return "Received malformed content. Error may have been logged on the server to investigate further"
        case let .invalidResponseCode(code):
            return "Server returned invalid response code. Expected between the range 200-299. Server returned \(code)"
        case let .decodingError(message):
            return message
        }
    }
}

final class RequestHandler: RequestHandling {

    private let urlSession: URLSession
    private let decoder: JSONDecoder

    // We will use previousSearchTask variable to cancel the previous request in flight to make sure only one request is alive at any given moment
    private var previousSearchTask: URLSessionDataTask?

    init(urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    /// A method to request data for given API endpoint
    /// - Parameters:
    ///   - type: A decodable type to which to convert downloaded response
    ///   - route: An enum of type APIRoute encoding which endpoint we want to hit
    ///   - completion: A closure that gets executed after request completion
    func request<T: Decodable>(type: T.Type, route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) {

        // If the previous request is running, we need to cancel it
        cancelPreviousRequestIfRunning()

        let task = urlSession.dataTask(with: route.asRequest()) { [weak self] (data, response, error) in

            guard let self else { return }

            if let error = error {
                // If the previous request is cancelled which fresh request is initiated, this is expected. We don't want to show error message to users in this case.
                guard (error as? URLError)?.code != .cancelled else {
                    return
                }
                completion(.failure(.genericError(error.localizedDescription)))
                return
            }

            // We want to make sure we receive non-nil, non-empty data from given endpoint
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noData))
                return
            }

            // Consider only responses with 200 response code as valid responses from API
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, responseCode != 200 {
                completion(.failure(.invalidResponseCode(responseCode)))
                return
            }

            do {
                let responsePayload = try self.decoder.decode(type.self, from: data)
                completion(.success(responsePayload))
            } catch let error {
                completion(.failure(.malformedContent))
                print("Failed to decode incoming JSON due to error : \((error as NSError).localizedDescription)")
            }
        }

        previousSearchTask = task
        task.resume()
    }

    // Cancel the previous request in flight to avoid duplication of data
    // This can happen when we're sending updated requests to same endpoint while
    // We only want to consider response from most recent call to API
    func cancelPreviousRequestIfRunning() {
        if let previousTask = previousSearchTask, previousTask.state == .running {
            previousTask.cancel()
        }
    }
}

