//
//  NewsListViewController.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit
import Combine
import SnapKit

class NewsListViewController: UIViewController, LoadableViewController {
    
    //MARK: Dependecies
    private let viewModel: NewsListViewModel
    
    //MARK: Stored Properties
    private let viewModelInput: NewsListViewModel.Input!

    var loaderOverlay = LoaderOverlay()
    var disposeBag = Set<AnyCancellable>()
    
    //MARK: Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    //MARK: Init
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        self.viewModelInput = NewsListViewModel.Input(inputSubject: CurrentValueSubject<InputAction, Never>(.loadData(showLoader: true)))
        self.viewModel.output = viewModel.transform(input: self.viewModelInput)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("NewsList View Controller deinit")
    }
}


//MARK: - Lifecycle
extension NewsListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModelInput.inputSubject.send(.refreshIfNeeded)
    }
}

//MARK: - UI
extension NewsListViewController {
    func setupView() {
        addViews()
        configureRefreshControl()
        setupLayout()
        setupTableView()
        setupBindings()
    }
    
    func addViews() {
        tableView.addSubview(refreshControl)
        view.addSubview(tableView)
    }
    
    func configureRefreshControl() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsListTableViewCell.self, forCellReuseIdentifier: NewsListTableViewCell.reuseIdentifier)
    }
}

//MARK: - TableViewDelegates
extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.screenData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let screenData = viewModel.output.screenData
        let cellData = screenData[indexPath.item]
        
        let cell: NewsListTableViewCell = tableView.dequeue(for: indexPath)
        
        cell.configure(with: cellData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModelInput.inputSubject.send(.openDetails(ofIndexPath: indexPath))
    }
}

//MARK: - ViewController Bindings
extension NewsListViewController {
    func setupBindings() {
        initializeLoaderSubject(viewModel.loaderPublisher).store(in: &disposeBag)
        
        viewModel.output.outputSubject
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .sink { [weak self] outputAction in
                switch outputAction {
                case .dataReady:
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                case.gotError(let message):
                    self?.showAlert(withMessage: message)
                }
            }
            .store(in: &disposeBag)
    }
}

//MARK: - Private Methods
private extension NewsListViewController {
    @objc func refreshData() {
        viewModelInput.inputSubject.send(.refresh(withLoader: false))
    }
    
    @objc func appMovedToForeground() {
        viewModelInput.inputSubject.send(.refreshIfNeeded)
    }
}

extension NewsListViewController {
    func setCoordinatorDelegate(_ coordinatorDelegate: NewsListCoordinatorDelegate) {
        viewModel.coordinatorDelegate = coordinatorDelegate
    }
}
