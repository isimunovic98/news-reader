//
//  SerializationManager.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

public final class SerializationManager {
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .deferredToData
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    public static func parseData<T: Codable>(jsonString: String) -> T? {
        guard let jsonData = jsonString.data(using: .utf8)
        else {
            return nil
        }
        
        return parseData(jsonData: jsonData)
    }
    
    public static func parseData<T: Codable>(jsonData: Data) -> T? {
        let object: T?
        do {
            object = try jsonDecoder.decode(T.self, from: jsonData)
        } catch let error {
            debugPrint("Error while parsing data from server. Received dataClassType: \(T.self). More info: \(error)")
            object=nil
        }
        return object
    }
}
