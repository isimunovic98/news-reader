//
//  Articles.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

struct Articles: Codable {
    var status: String
    var source: String
    var sortBy: String
    var articles: [Article]
}
