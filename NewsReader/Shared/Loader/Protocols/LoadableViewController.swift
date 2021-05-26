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


extension LoadableViewController where Self: UIViewController {
    func initializeLoaderSubject(_ subject: PassthroughSubject<Bool, Never>) -> AnyCancellable {
        return subject
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { [unowned self] (showLoader) in
                if (showLoader) {
                    self.showLoader()
                } else {
                    self.dismissLoader()
                }
            }
    }
}

private extension LoadableViewController where Self: UIViewController {
    func showLoader() {
        loaderOverlay.showLoader(viewController: self)
    }
    
    func dismissLoader() {
        loaderOverlay.dismissLoader()
    }
}
