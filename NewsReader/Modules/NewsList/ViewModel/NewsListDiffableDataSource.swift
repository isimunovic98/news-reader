//
//  NewsListDiffableDataSource.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 30.05.2021..
//

import UIKit

class NewsListDiffableDataSource: UITableViewDiffableDataSource<Section, ArticleViewModel> {}

class NewsListSnapshot {
    var snapshot = NSDiffableDataSourceSnapshot<Section, ArticleViewModel>()
}
