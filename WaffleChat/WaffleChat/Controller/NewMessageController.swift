//
//  NewMessageController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/09.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol NewMessageViewModelBindable: ViewModelType {
    // Input -> ViewModel
    var refreshPulled: PublishRelay<Void> { get }
    var filterKey: PublishRelay<String> { get }
    var searchCancelButtonTapped: PublishRelay<Void> { get }
    
    // ViewModel -> OutPut
    var users: BehaviorRelay<[User]> { get }
    var isNetworking: PublishRelay<Bool> { get }
    
}

final class NewMessageController: UIViewController, ViewType {
    
    // MARK: - Properties
    let tableView = UITableView()
    let refresh = UIRefreshControl()
    let searchController = UISearchController()
    
    var viewModel: NewMessageViewModelBindable!
    var disposeBag: DisposeBag!
    
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(with: "Friend List", prefersLargeTitles: false)
    }
    
    // MARK: - Initial Setup
    func setupUI() {
        configureTableView()
        configureNaviBar()
        configureSearchBar()
        configureRefreshController()
    }
    
    private func configureNaviBar() {
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame = view.frame
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
    
    private func configureSearchBar() {
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func configureRefreshController() {
        refresh.tintColor = #colorLiteral(red: 0.6179639697, green: 0.421579957, blue: 0.1246413961, alpha: 1)
        self.tableView.refreshControl = refresh
    }
    
    
    // MARK: - Binding
    func bind() {
        
        // Action Bind
        refresh.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshPulled)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .bind(to: viewModel.searchCancelButtonTapped)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.filterKey)
            .disposed(by: disposeBag)
        
        // UI Bind
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        // State Bind
        viewModel.users
            .bind(to: tableView.rx.items(cellIdentifier: UserCell.reuseIdentifier,
                                         cellType: UserCell.self)) { indexPath, user, cell in
                cell.user = user
            }
            .disposed(by: disposeBag)
        
        viewModel.isNetworking
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                if $0 {
                    self?.refresh.beginRefreshing()
                } else {
                    self?.refresh.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }

}



