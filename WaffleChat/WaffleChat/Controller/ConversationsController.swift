//
//  ConversationsController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/06/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class ConversationsController: UIViewController {

    private let reuseIdentifier = "ConversationCell"
    
    private let newMessageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(didTapNewMessageButton), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Properties
    let tableView = UITableView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(with: "Messages", prefersLargeTitles: true)
        configureTableView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle.fill"),
                                                           style: .plain, target: self,
                                                           action: #selector(didTapProfileButton))
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
    
    
    // MARK: - Action Handler
    @objc private func didTapProfileButton() {
        print("profile")
        doLogoutThisUser { (error) in
            if let err = error {
                print("Failed to logged out:", err)
                return
            }
            print("Successfully logged out this user")
            switchToLoginVC()
        }
    }
    
    @objc private func didTapNewMessageButton() {
        print("tap newMessage")
        let newMessageVC = UINavigationController(rootViewController: NewMessageController())
        newMessageVC.modalPresentationStyle = .fullScreen
        present(newMessageVC, animated: true)
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
