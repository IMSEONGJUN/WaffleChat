//
//  ConversationsController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/06/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    private let newMessageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1)
        btn.tintColor = .white
        return btn
    }()
    
    let tableView = UITableView()
    var disposeBag = DisposeBag()
    var viewModel = ConversationViewModel()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(with: "Messages", prefersLargeTitles: true)
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .white
        configureTableView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle.fill"),
                                                           style: .plain, target: nil, action: nil)
        configureNewMessageButton()
        
    }
    
    private func configureNewMessageButton() {
        view.addSubview(newMessageButton)
        newMessageButton.layer.cornerRadius = 56 / 2
        newMessageButton.clipsToBounds = true
        newMessageButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            $0.trailing.equalTo(view.snp.trailing).inset(24)
            $0.width.height.equalTo(56)
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .systemBackground
        tableView.frame = view.frame
        tableView.tableFooterView = UIView()
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
    }
    
    func bind() {
        // Action Bind
        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [unowned self] in
                let profileController = ProfileController(style: .insetGrouped)
                let navi = UINavigationController(rootViewController: profileController)
                navi.modalPresentationStyle = .fullScreen
                navi.modalTransitionStyle = .coverVertical
                self.present(navi, animated: true)
            })
            .disposed(by: disposeBag)
        
        newMessageButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                let newMessageVC = NewMessageController()
                self.newMessageControllerBind(newMsgVC: newMessageVC)
                let newMessageVCNavi = UINavigationController(rootViewController: newMessageVC)
                newMessageVCNavi.modalPresentationStyle = .fullScreen
                self.present(newMessageVCNavi, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[unowned self] indexPath in
                guard let cell = self.tableView.cellForRow(at: indexPath) as? ConversationCell else { return }
                guard let user = cell.conversation?.user else { return }
                let chatVC = ChatController(user: user)
                self.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // State Bind
        viewModel.conversations
            .bind(to: tableView.rx.items(cellIdentifier: ConversationCell.reuseIdentifier,
                                         cellType: ConversationCell.self)){ indexPath, conversation, cell in
                                            cell.conversation = conversation
                                         }
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Binding Helper
    func newMessageControllerBind(newMsgVC: NewMessageController) {
        newMsgVC.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                guard let cell = newMsgVC.tableView.cellForRow(at: indexPath) as? UserCell else { return }
                guard let user = cell.user else { return }
                let chatVC = ChatController(user: user)
                newMsgVC.searchController.dismiss(animated: true)
                newMsgVC.dismiss(animated: true)
                self.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
