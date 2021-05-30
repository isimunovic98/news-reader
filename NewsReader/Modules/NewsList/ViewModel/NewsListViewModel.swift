//
//  NewsListViewModel.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import Foundation
import Combine

enum NewsListInput {
    case loadData(showLoader: Bool)
    case refreshIfNeeded
    case pullToRefresh
    case showDetails(ofIndexPath: IndexPath)
}

enum NewsListOutput {
    case showLoader(Bool)
    case stopRefresh
    case gotError(String)
}

final class NewsListViewModel {
    var input = CurrentValueSubject<NewsListInput, Never>(.loadData(showLoader: true))
    var output: Output!
    var dependencies: Dependencies!
    
    struct Dependencies {
        let repository: NewsRepository
        weak var coordinatorDelegate: NewsListCoordinatorDelegate?
    }
    
    struct Output {
        var snapshot: NewsListSnapshot
        var outputActions: [NewsListOutput]
        let outputSubject: PassthroughSubject<[NewsListOutput], Never>
    }
    
    //MARK: Internal Properties
    internal var isRefreshNeeded: Bool {
        guard let lastUpdate = self.lastUpdate else {
            return false
        }
        let expression = lastUpdate.addingTimeInterval(300) < Date()
        return expression
    }

    internal var lastUpdate: Date?
    
    var diffableDataSource: NewsListDiffableDataSource!
    
    
    //MARK: Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.output = Output(snapshot: NewsListSnapshot(),
                             outputActions: [],
                             outputSubject: PassthroughSubject<[NewsListOutput], Never>())
    }
    
    deinit {
        debugPrint("NewList ViewModel deinit")
    }
}

//MARK: - Binding
extension NewsListViewModel {
    func setupBindings() -> AnyCancellable {
        return input
            .flatMap { [unowned self] inputAction -> AnyPublisher<[NewsListOutput], Never> in
                //awfull
                switch inputAction {
                case .loadData(let showLoader):
                    return self.handleLoadScreenData(showLoader)
                case .refreshIfNeeded:
                    if (self.isRefreshNeeded) {
                        return self.handleLoadScreenData(true)
                    }
                case .pullToRefresh:
                    return self.handleLoadScreenData(false)
                case .showDetails(let indexPath):
                    return handleShowDetails(of: indexPath)
                }
                
                return Just(self.output.outputActions).eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { [unowned self] outputActions in
                self.output.outputSubject.send(outputActions)
            }
    }
}

//MARK: - Private Methods
private extension NewsListViewModel {
    func handleLoadScreenData(_ showLoader: Bool) -> AnyPublisher<[NewsListOutput], Never> {
        var outputActions = [NewsListOutput]()
        return dependencies.repository.getNewsList()
            .map({ [unowned self] responseResult -> Result<[ArticleViewModel], NetworkError> in
                //self.output.outputActions.append(.showLoader(showLoader))
                self.output.outputSubject.send([.showLoader(showLoader)])
                switch responseResult {
                case .success(let articlesResponse):
                    let screenData = self.createNewsListScreenData(from: articlesResponse.articles)
                    return .success(screenData)
                case .failure(let error):
                    return .failure(error)
                }
            })
            .flatMap { [unowned self] responseResult -> AnyPublisher<[NewsListOutput], Never> in
                outputActions.append(.showLoader(false))
                //self.output.outputSubject.send([.showLoader(false)])
                switch responseResult {
                case .success(let screenData):
                    applySnapshot(with: screenData)
                    self.lastUpdate = Date()
                    outputActions.append(.stopRefresh)
                case .failure(let error):
                    outputActions.append(.gotError(error.localizedDescription))
                }
                
                return Just(outputActions).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func handleShowDetails(of indexPath: IndexPath) -> AnyPublisher<[NewsListOutput], Never> {
        let outputActions = [NewsListOutput]()
        dependencies.coordinatorDelegate?.openDetails(of: indexPath)
        return Just(outputActions).eraseToAnyPublisher()
    }
    
    func applySnapshot(with screenData: [ArticleViewModel],animatingDifferences: Bool = true) {
        output.snapshot.snapshot.deleteAllItems()
        output.snapshot.snapshot.appendSections([.main])
        output.snapshot.snapshot.appendItems(screenData)
        diffableDataSource.apply(output.snapshot.snapshot, animatingDifferences: animatingDifferences)
    }
    
    func createNewsListScreenData(from response: [Article]) -> [ArticleViewModel] {
        var temp = [ArticleViewModel]()
        if response.isEmpty {
            //APPEND EMMPTY STATE
            return temp
        }
        temp = response.map({ ArticleViewModel($0) })
        return temp
    }
}
