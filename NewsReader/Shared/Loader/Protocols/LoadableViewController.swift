//
//  LoadableViewController.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit
import Combine

protocol LoadableViewController {
    var loaderOverlay: LoaderOverlay {get}
    var disposeBag: Set<AnyCancellable> {get}
}

private extension LoadableViewController where Self: UIViewController {
    func showLoader() {
        loaderOverlay.showLoader(viewController: self)
    }
    
    func dismissLoader() {
        loaderOverlay.dismissLoader()
    }
}
