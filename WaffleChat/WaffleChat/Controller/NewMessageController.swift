//
//  NewMessageController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/09.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit


class NewMessageController: UIViewController {
    
    // MARK: - Properties
    let tableView = UITableView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .yellow
        configureTableView()
        configureNaviBar()
        configureSearchBar()
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
    
    
    // MARK: - Action Handler
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    
}


// MARK: - UITableViewDataSource
extension NewMessageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
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
