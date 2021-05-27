//
//  NewsListViewModel.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

enum Action {
    case refresh(withLoader: Bool)
    case refreshIfNeeded
    case openDetails(ofIndexPath: IndexPath)
}

enum OutputAction {
    case dataReady
    case gotError(String)
}

final class NewsListViewModel: ViewModelType, LoadableViewModel {
    
    var output: Output!
    var input: Input!
    let dependencies: Dependencies!
    
    struct Dependencies {
        let repository: NewsRepository
    }
    
    struct Input {
        let loadDataSubject: CurrentValueSubject<Bool, Never>
        let actionHandlerSubject: PassthroughSubject<Action, Never>
    }
    
    struct Output {
        let disposables: [AnyCancellable]
        var screenData: [ArticleViewModel]
        let outputSubject: PassthroughSubject<OutputAction, Never>
    }
    
    //MARK: Dependencies
    weak var coordinatorDelegate: NewsListCoordinatorDelegate?
    
    //MARK: Stored Properties
    var lastUpdate: Date?
    
    //MARK: Protocol Conformance
    var loaderPublisher = PassthroughSubject<Bool, Never>()
    
    //MARK: Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    deinit {
        debugPrint("NewList ViewModel deinit")
    }
    
    func transform(input: Input) -> Output {
        self.input = input
        var disposables = [AnyCancellable]()
        disposables.append(initializeLoadData(input.loadDataSubject))
        disposables.append(initializeActionHandler(input.actionHandlerSubject))
        self.output = Output(disposables: disposables,
                             screenData: [],
                             outputSubject: PassthroughSubject<OutputAction, Never>())
        return output
    }
}

extension NewsListViewModel {
    func initializeLoadData(_ subject: CurrentValueSubject<Bool, Never>) -> AnyCancellable {
        return subject
            .flatMap { [unowned self] (shouldShowLoader) -> AnyPublisher<Result<Articles, NetworkError>, Never> in
                self.loaderPublisher.send(shouldShowLoader)
                return self.dependencies.repository.getNewsList()
            }
            .map({ responseResult -> Result<[ArticleViewModel], NetworkError> in
                switch responseResult {
                case .success(let articlesResponse):
                    let screenData = self.createScreenData(from: articlesResponse.articles)
                    return .success(screenData)
                case .failure(let error):
                    return .failure(error)
                }
            })
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { [unowned self] responseResult in
                self.loaderPublisher.send(false)
                switch responseResult {
                case .success(let screenData):
                    self.output.screenData = screenData
                    self.output.outputSubject.send(.dataReady)
                    self.lastUpdate = Date()
                case .failure(let error):
                    self.output.outputSubject.send(.gotError(error.localizedDescription))
                }
            }
    }
    
    func initializeActionHandler(_ subject: PassthroughSubject<Action, Never>) -> AnyCancellable {
        return subject
            .map { [unowned self] (action) in
                switch action {
                case .openDetails(let indexPath):
                    self.coordinatorDelegate?.openDetails(of: indexPath)
                case .refresh(let shouldShowLoader):
                    self.input.loadDataSubject.send(shouldShowLoader)
                case .refreshIfNeeded:
                    if (self.isRefreshNeeded()) {
                        self.input.loadDataSubject.send(true)
                    }
                }
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { (_) in
                
            }
    }
}


//MARK: - Private Methods
private extension NewsListViewModel {
    func createScreenData(from response: [Article]) -> [ArticleViewModel] {
        var temp = [ArticleViewModel]()
        if response.isEmpty {
            //APPEND EMMPTY STATE
            return temp
        }
        temp = response.map({ ArticleViewModel($0) })
        return temp
    }
    
    func isRefreshNeeded() -> Bool {
        guard let lastUpdate = self.lastUpdate else {
            return false
        }
        return lastUpdate.addingTimeInterval(300) > Date()
    }
}
