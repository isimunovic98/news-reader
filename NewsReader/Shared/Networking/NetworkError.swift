//
//  NetworkError.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

public enum NetworkError: Error {
    case generalError
    case parseFailed
    case invalidUrl
    case notConnectedToInternet
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parseFailed:
            return "Parse failed"
        case .generalError:
            return "An error occured, please try again"
        case .invalidUrl:
            return "Invalid URL"
        case .notConnectedToInternet:
            return "You are not connected to interner, check your connection and try again"
        }
    }
}
