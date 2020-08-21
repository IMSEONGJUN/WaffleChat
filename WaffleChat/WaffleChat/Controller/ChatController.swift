//
//  ChatController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/16.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    var user: User?
    
    private lazy var customInputView = CustomInputAccessoryView(frame:
                                                                CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    var viewModel: ChatViewModel
    var disposeBag = DisposeBag()
    var messageToSend = BehaviorRelay<String>(value: "")
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureCollectionView()
        bind()
    }
    
    
    // MARK: - Override
    override var inputAccessoryView: UIView? {
        return customInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: - Custom Initializer
    init(user: User) {
        self.viewModel = ChatViewModel(user: user)
        print("init")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Initial Setup
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: configureFlowLayout())
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
    
    
    // MARK: - Bind
    func bind() {
        viewModel.user
            .subscribe(onNext: { [weak self] in
                guard let user = $0 else { return }
                self?.user = user
                self?.configureNavigationBar(with: user.username, prefersLargeTitles: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.messages
            .bind(to: collectionView.rx.items(cellIdentifier: MessageCell.reuseID,
                                              cellType: MessageCell.self)) {[weak self] indexPath, message, cell in
                                                cell.message?.user = self?.user
                                                cell.message = message
            }
            .disposed(by: disposeBag)
        
        customInputView.messageInputTextView.rx.text
            .orEmpty
            .bind(to: messageToSend)
            .disposed(by: disposeBag)
        
        customInputView.sendButton.rx.tap
            .map({ Observable.zip(self.messageToSend, self.viewModel.user) })
            .flatMapLatest{$0}
            .subscribe(onNext:{
                APIManager.shared.uploadMessage($0.0, To: $0.1!) { [weak self] (error) in
                    if let error = error {
                        print("Failed to upload message:", error)
                        return
                    }
                    self?.customInputView.clearMessageText()
                    print("Succesfully uploaded message")
                }
            })
            .disposed(by: disposeBag)
        
        
    }
}
