//
//  NewsRepositoryImpl.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

class NewsRepositoryImpl: NewsRepository {
    static let urlString = "https://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=a722050f35004a06a0e02640a367265d"
    
    func getNewsList() -> AnyPublisher<Result<Articles, NetworkError>, Never> {
        return RestManager.requestObservable(url: NewsRepositoryImpl.urlString)
    }
}
