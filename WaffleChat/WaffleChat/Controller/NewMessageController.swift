//
//  NewMessageController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/09.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift

class NewMessageController: UIViewController {
    
    // MARK: - Properties
    let tableView = UITableView()
    
    let viewModel = NewMessageViewModel()
    var disposeBag = DisposeBag()
    let refresh = UIRefreshControl()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configure { (_) in
            print("fetched Users")
        }
        configureUI()
    }
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .yellow
        configureTableView()
        configureNaviBar()
        configureSearchBar()
        configureRefreshController()
        bind()
    }
    
    private func configureNaviBar() {
        configureNavigationBar(with: "New Message", prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame = view.frame
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func configureRefreshController() {
        refresh.tintColor = #colorLiteral(red: 0.6179639697, green: 0.421579957, blue: 0.1246413961, alpha: 1)
        self.tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func bind() {
        viewModel.users.bind {[unowned self] (_) in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Action Handler
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func handleRefresh() {
        let group = DispatchGroup()
        group.enter()
        viewModel.configure { (_) in
            group.leave()
            print("refetch users")
        }
        
        group.notify(queue: .main) {
            self.tableView.refreshControl?.endRefreshing()
            print("refreshing")
        }
    }
    
}


// MARK: - UITableViewDataSource
extension NewMessageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        cell.user = viewModel.users.value?[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension NewMessageController: UITableViewDelegate {
    
}


// MARK: - UISearchResultsUpdating
extension NewMessageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
