//
//  NewsRepository.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

protocol NewsRepository {
    func getNewsList() -> AnyPublisher<Result<Articles, NetworkError>, Never>
}
