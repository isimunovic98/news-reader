//
//  LoadableViewModel.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

protocol LoadableViewModel {
    var loaderPublisher: PassthroughSubject<Bool, Never> { get }
}
