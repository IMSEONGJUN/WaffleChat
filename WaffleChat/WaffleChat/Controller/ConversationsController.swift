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

protocol ConversationViewModelBindable: ViewModelType {
    //Output
    var conversations: BehaviorRelay<[Conversation]> { get }
}


final class ConversationsController: UIViewController, ViewType {
    
    // MARK: - Properties
    private let newMessageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1)
        btn.tintColor = .white
        return btn
    }()
    
    private let tableView = UITableView()
    var disposeBag: DisposeBag!
    var viewModel: ConversationViewModelBindable!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ConversationVC viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(with: "Messages", prefersLargeTitles: true)
    }
    
    
    // MARK: - Initial Setup
    func setupUI() {
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
    
    
    // MARK: - Binding
    func bind() {
        // UI Binding
        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [unowned self] in
                let profileController = ProfileController.create(with: ProfileViewModel())
                let navi = UINavigationController(rootViewController: profileController)
                navi.modalPresentationStyle = .fullScreen
                navi.modalTransitionStyle = .coverVertical
                self.present(navi, animated: true)
            })
            .disposed(by: disposeBag)
        
        newMessageButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                let newMessageVC = NewMessageController.create(with: NewMessageViewModel())
                self.newMessageControllerBind(newMsgVC: newMessageVC)
                let newMessageVCNavi = UINavigationController(rootViewController: newMessageVC)
                newMessageVCNavi.modalPresentationStyle = .fullScreen
                self.present(newMessageVCNavi, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Conversation.self)
            .subscribe(onNext: {[unowned self] conversation in
                let chatVC = ChatController.create(with: ChatViewModel(user: conversation.user))
                self.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] in
                self.tableView.deselectRow(at: $0, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // ViewModel -> Output
        viewModel.conversations
            .bind(to: tableView.rx.items(cellIdentifier: ConversationCell.reuseIdentifier,
                                         cellType: ConversationCell.self)){ row, conversation, cell in
                                            cell.conversation = conversation
                                         }
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Binding Helper
    func newMessageControllerBind(newMsgVC: NewMessageController) {
        newMsgVC.tableView.rx.modelSelected(User.self)
            .subscribe(onNext: { [weak self] user in
                let chatVC = ChatController.create(with: ChatViewModel(user: user))
                newMsgVC.searchController.dismiss(animated: true)
                newMsgVC.dismiss(animated: true)
                self?.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
