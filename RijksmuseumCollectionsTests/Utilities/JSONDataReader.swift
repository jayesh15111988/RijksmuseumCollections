//
//  JSONDataReader.swift
//  RijksmuseumCollectionsTests
//
//  Created by Jayesh Kawli on 6/23/23.
//

import XCTest

final class JSONDataReader {

    /// A method to get the specified Decodable model after converting local JSON data into model object
    /// - Parameter name: Name of the JSON file to read the data from
    /// - Returns: A specified Decodable model objet
    static func getModelFromJSONFile<T: Decodable>(with name: String) -> T? {

        guard let jsonData = getDataFromJSONFile(with: name) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: jsonData)
    }

    /// A method to get Data for JSON values read from local JSON file
    /// - Parameter name: Name of the JSON file to read the data from
    /// - Returns: A Data object if data or file exists, otherwise nil
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
