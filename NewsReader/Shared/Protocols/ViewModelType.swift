//
//  ViewModelType.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
