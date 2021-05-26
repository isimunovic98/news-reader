//
//  ArticleViewModel.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

struct ArticleViewModel {
    var author: String
    var title: String
    var description: String
    var url: String
    var urlToImage: String
    var publishedAt: String?
    
    init(_ article: Article) {
        self.author = article.author
        self.title = article.title
        self.description = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
    }
}
