//
//  AppCoordinator.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController = .init()
    let window: UIWindow
    
    init() { self.window = UIWindow(frame: UIScreen.main.bounds) }
    deinit { print("AppCoordinator deinit called.") }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        presentNewsList()
    }
    
    func presentNewsList() {
        let child = NewsListCoordinator(presenter: presenter)
        childCoordinators.append(child)
        child.start()
    }
}
