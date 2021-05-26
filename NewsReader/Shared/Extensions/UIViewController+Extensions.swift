//
//  UIViewController+Extensions.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit

extension UIViewController {
    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
