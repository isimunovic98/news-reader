//
//  NewsListCoordinator.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit

class NewsListCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var presenter: UINavigationController
    let controller: NewsListViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.controller = NewsListCoordinator.createController()
        controller.setCoordinatorDelegate(self)
    }
    
    deinit {
        debugPrint("NewList Coordinator deinit!")
    }
    
    func start() {
        presenter.pushViewController(controller, animated: true)
    }
    
    static func createController() -> NewsListViewController {
        let repository = NewsRepositoryImpl()
        let dependencies = NewsListViewModel.Dependencies(repository: repository)
        let viewModel = NewsListViewModel(dependencies: dependencies)
        let viewController = NewsListViewController(viewModel: viewModel)
        return viewController
    }
}

extension NewsListCoordinator: NewsListCoordinatorDelegate {
    func openDetails(of indexPath: IndexPath) {
        debugPrint("opening details of \(indexPath.item)")
    }
}
