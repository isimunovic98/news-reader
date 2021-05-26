//
//  NewsRepositoryImpl.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

class NewsRepositoryImpl: NewsRepository {
    static let urlString = "https://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=3499bde5ea0c4c5e8eb1170463d63564"
    
    func getNewsList() -> AnyPublisher<Result<Articles, NetworkError>, Never> {
        return RestManager.requestObservable(url: NewsRepositoryImpl.urlString)
    }
}
