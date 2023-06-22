//
//  RequestHandling.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import Foundation

protocol RequestHandling {
    func request<T: Decodable>(type: T.Type, route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void)
}

