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

    private let reuseIdentifier = "ConversationCell"
    
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
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(with: "Messages", prefersLargeTitles: true)
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
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func bind() {
        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: {
                print("profile")
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
        
        newMessageButton.rx.tap
            .subscribe(onNext:{ [weak self] in
                guard let self = self else { return }
                let newMessageVC = NewMessageController()
                newMessageVC.delegate = self
                let newMessageVCNavi = UINavigationController(rootViewController: newMessageVC)
                newMessageVCNavi.modalPresentationStyle = .fullScreen
                self.present(newMessageVCNavi, animated: true)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UITableViewDataSource
extension ConversationsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Test Cell"
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ConversationsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

// MARK: - NewMessageControllerDelegate
extension ConversationsController: NewMessageControllerDelegate {
    func newChatStarted(toRemove controller: NewMessageController, startWithUser user: User) {
        controller.dismiss(animated: true)
        let chatVC = ChatController(user: user)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
