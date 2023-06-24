//
//  JSONDataReader.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

final class JSONDataReader {
    static func getModelFromJSONFile<T: Decodable>(with name: String) -> T? {

        guard let jsonData = self.getDataFromJSONFile(with: name) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: jsonData)
    }

    static func getDataFromJSONFile(with name: String) -> Data? {
        guard let pathString = Bundle(for: self).path(forResource: name, ofType: "json") else {
            XCTFail("Mock JSON file \(name).json not found")
            return nil
        }

        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            return nil
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return jsonData
    }
}

