//
//  ProfileController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/31.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileController: UITableViewController {
    
    // MARK: - Properties
    private lazy var headerView = ProfileHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 380))
    private lazy var footerView = ProfileFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    let disposeBag = DisposeBag()
    let viewModel = ProfileViewModel()
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("controller")
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - Initial setup
    func configureUI() {
        tableView.backgroundColor = .white
        tableView.tableHeaderView = headerView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.reuseID)
        tableView.rowHeight = 80
        tableView.tableFooterView = footerView
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    
    // MARK: - Bind
    func bind() {
        headerView.dismissButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.user
            .subscribe(onNext: { [unowned self] in
                guard let user = $0 else { return }
                self.headerView.user.accept(user)
            })
            .disposed(by: disposeBag)
        
        footerView.logoutButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                self.doLogoutThisUser {[weak self] (error) in
                    if let err = error {
                        print("Failed to logged out:", err)
                        return
                    }
                    print("Successfully logged out this user")
                    self?.switchToLoginVC()
                }
            })
            .disposed(by: disposeBag)
    }
}


extension ProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileControllerTableViewCellType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.reuseID, for: indexPath) as! ProfileCell
        
        let cellType = ProfileControllerTableViewCellType(rawValue: indexPath.row)
        cell.cellType = cellType
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ProfileController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
                
