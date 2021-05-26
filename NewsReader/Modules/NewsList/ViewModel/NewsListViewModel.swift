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

final class NewsListViewModel: LoadableViewModel {
    //MARK: Dependencies
    private let repository: NewsRepository
    weak var coordinatorDelegate: NewsListCoordinatorDelegate?
    
    //MARK: Stored Properties
    var screenData = [ArticleViewModel]()
    var lastUpdate: Date?
    
    //MARK: Protocol Conformance
    var loaderPublisher = PassthroughSubject<Bool, Never>()
    
    //MARK: Subjects
    let loadDataSubject = CurrentValueSubject<Bool, Never>(true)
    let screenDataReady = PassthroughSubject<Void, Never>()
    let errorPublisher = PassthroughSubject<String, Never>()
    let actionHandlerSubject = PassthroughSubject<Action, Never>()
    
    //MARK: Init
    init(repository: NewsRepository) {
        self.repository = repository
    }
    
    deinit {
        debugPrint("NewList ViewModel deinit")
    }
}

extension NewsListViewModel {
    func initializeScreenData(_ subject: CurrentValueSubject<Bool, Never>) -> AnyCancellable {
        return subject
            .flatMap { [unowned self] (shouldShowLoader) -> AnyPublisher<Result<Articles, NetworkError>, Never> in
                self.loaderPublisher.send(shouldShowLoader)
                return self.repository.getNewsList()
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
                    self.screenData = screenData
                    self.screenDataReady.send()
                    self.lastUpdate = Date()
                case .failure(let error):
                    self.errorPublisher.send(error.localizedDescription)
                }
            }
    }
    
    func attachActionListener(_ subject: PassthroughSubject<Action, Never>) -> AnyCancellable {
        return subject
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { [unowned self] (action) in
                switch action {
                case .refresh(let shouldShowLoader):
                    self.loadDataSubject.send(shouldShowLoader)
                case .refreshIfNeeded:
                    if (self.isRefreshNeeded()) {
                        self.loadDataSubject.send(true)
                    }
                case .openDetails(let indexPath):
                    self.coordinatorDelegate?.openDetails(of: indexPath)
                }
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
