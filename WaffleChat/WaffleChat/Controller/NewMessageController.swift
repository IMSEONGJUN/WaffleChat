//
//  NewMessageController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/09.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift

final class NewMessageController: UIViewController {
    
    // MARK: - Properties
    let tableView = UITableView()
    let refresh = UIRefreshControl()
    let searchController = UISearchController()
    
    let viewModel = NewMessageViewModel()
    var disposeBag = DisposeBag()
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .yellow
        configureTableView()
        configureNaviBar()
        configureSearchBar()
        configureRefreshController()
    }
    
    private func configureNaviBar() {
        configureNavigationBar(with: "Friend List", prefersLargeTitles: false)
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
    private func bind() {
        // State Bind
        viewModel.users
            .bind(to: tableView.rx.items(cellIdentifier: UserCell.reuseIdentifier,
                                         cellType: UserCell.self)) { indexPath, user, cell in
                cell.user = user
            }
            .disposed(by: disposeBag)
        
        viewModel.isNetworking
            .subscribe(onNext: {[weak self] in
                if $0 {
                    self?.refresh.beginRefreshing()
                } else {
                    self?.refresh.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        
        // Action Bind
        refresh.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshPulled)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [unowned self] in
                self.viewModel.fetchUsers()
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map{ $0.lowercased() }
            .subscribe(onNext: { [unowned self] str in
                if str == "" {
                    self.viewModel.fetchUsers()
                    return
                }
                let filteredUsers = self.viewModel.filteredUsers
                                                  .filter{ $0.fullname.lowercased().contains(str)
                                                           || $0.username.lowercased().contains(str) }
                self.viewModel.users.accept(filteredUsers)
            })
            .disposed(by: disposeBag)
    }

}



