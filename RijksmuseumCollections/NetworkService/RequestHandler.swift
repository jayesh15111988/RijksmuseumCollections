//
//  RequestHandler.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

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

    let urlSession: URLSession

    // We will use previousSearchTask variable to cancel the previous request in flight to make sure only one request is alive at any given moment
    private var previousSearchTask: URLSessionDataTask?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<T: Decodable>(type: T.Type, route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) {

        cancelPreviousRequestIfRunning()

        let task = urlSession.dataTask(with: route.asRequest()) { (data, response, error) in

            if let error = error {
                guard (error as? URLError)?.code != .cancelled else {
                    return
                }
                completion(.failure(.genericError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let responseCode = (response as? HTTPURLResponse)?.statusCode, responseCode != 200 {
                completion(.failure(.invalidResponseCode(responseCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let responsePayload = try decoder.decode(type.self, from: data)
                completion(.success(responsePayload))
            } catch {
                completion(.failure(.malformedContent))
            }
        }

        previousSearchTask = task
        task.resume()
    }

    // Cancel the previous request in flight to avoid duplication of data
    func cancelPreviousRequestIfRunning() {
        if let previousTask = previousSearchTask, previousTask.state == .running {
            previousTask.cancel()
        }
    }
}

