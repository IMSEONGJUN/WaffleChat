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
    
    private let customInputView = CustomInputAccessoryView()
    private var viewModel: ChatViewModel
    private var disposeBag = DisposeBag()
    
    private var token: NSObjectProtocol?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureCollectionView()
        configureCustomInputView()
        bind()
        configureNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        let lastMessage = viewModel.messages.value.last
//        let user = self.user
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let count = self.viewModel.messages.value.count
        self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
        
    }
    
    // MARK: - Override
//    override var inputAccessoryView: UIView? {
//        return customInputView
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    
    // MARK: - Custom Initializer
    init(user: User) {
        self.viewModel = ChatViewModel(user: user)
        print("init")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let token = self.token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Initial Setup
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
    
    func configureCustomInputView() {
        view.addSubview(customInputView)
        customInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
    }
    
    func configureNotification() {
        token = NotificationCenter.default.addObserver(forName: Notifications.didFinishFetchMessage, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let self = self else { return }
            print("notification comes")
            UIView.animate(withDuration: 0.1) {
                let count = self.viewModel.messages.value.count
                self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
                self.collectionView.layoutIfNeeded()
            }
        })
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
                                                var message = message
                                                message.user = self?.user
                                                cell.message = message
            }
            .disposed(by: disposeBag)

        
        customInputView.sendButton.rx.tap
            .flatMapLatest({
                Observable.zip(self.customInputView.messageInputTextView.rx.text.orEmpty, self.viewModel.user)
            })
            .filter({ $0.0 != "" && $0.1 != nil })
            .subscribe(onNext:{ [unowned self] in
                APIManager.shared.uploadMessage($0.0, To: $0.1!) { (error) in
                    if let error = error {
                        print("Failed to upload message:", error)
                        return
                    }
                    print("Succesfully uploaded message")
                }
                self.customInputView.clearMessageText()
            })
            .disposed(by: disposeBag)
        
        
        collectionView.rx.itemSelected
            .subscribe(onNext:{ _ in
                UIView.animate(withDuration: 0.5) {
                    self.customInputView.messageInputTextView.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext:{ [weak self] noti in
                guard let self = self else { return }
                guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
                }
                let keyboardFrame = value.cgRectValue
                self.collectionView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 30)
                self.customInputView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 30)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] noti in
                self?.collectionView.transform = .identity
                self?.customInputView.transform = .identity
            })
            .disposed(by: disposeBag)
        
    }
}
