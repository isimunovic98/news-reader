//
//  NewsListCoordinatorDelegate.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

protocol NewsListCoordinatorDelegate: AnyObject {
    func openDetails(of indexPath: IndexPath)
}
