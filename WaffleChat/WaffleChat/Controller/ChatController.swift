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

final class ChatController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    var user: User?
    
    private let customInputView = CustomInputAccessoryView()
    private var viewModel: ChatViewModel
    private var disposeBag = DisposeBag()
    
    private var token: NSObjectProtocol?
    private let tapGesture = UITapGestureRecognizer()
    let coverView = UIView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureCollectionView()
        configureCustomInputView()
        configureTapGesture()
        bind()
        configureNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coverView.backgroundColor = .white
        coverView.frame = collectionView.bounds
        collectionView.addSubview(coverView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if collectionView.contentSize.height > collectionView.frame.height {
            let collectionViewContentHeight = collectionView.contentSize.height
            let collectionViewHeight = collectionView.frame.height
            
            let number = Int(collectionView.contentSize.height / collectionView.frame.height)
            let remainder = collectionViewContentHeight.truncatingRemainder(dividingBy: collectionViewHeight)
            
            let lengthToScroll = ( (collectionViewHeight * CGFloat(number)) + remainder ) - collectionViewHeight
            collectionView.contentOffset.y = lengthToScroll
        }
        coverView.removeFromSuperview()
    }
    
    deinit {
        if let token = self.token {
            NotificationCenter.default.removeObserver(token)
        }
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
    
    func configureTapGesture() {
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    func configureNotification() {
        token = NotificationCenter.default.addObserver(forName: Notifications.didFinishFetchMessage,
                                                       object: nil,
                                                       queue: OperationQueue.main,
                                                       using: { [weak self] (noti) in
            guard let self = self else { return }
            let count = self.viewModel.messages.value.count
            self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
            self.collectionView.layoutIfNeeded()
        })
    }
    
    
    // MARK: - Binding
    func bind() {
        // State Binding
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

        viewModel.uploadedMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.customInputView.clearMessageText()
            })
            .disposed(by: disposeBag)
       
       // Action Binding
        customInputView.sendButton.rx.tap
            .bind(to: viewModel.sendButtonTapped)
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        customInputView.messageInputTextView.rx.text
            .orEmpty
            .bind(to: viewModel.inputText)
            .disposed(by: disposeBag)
            
        
        
        // Notification Binding
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext:{ [weak self] noti in
                guard let self = self else { return }
                let keyboardFrame = self.getKeyboardFrame(noti: noti)
                let bottomInset = self.view.safeAreaInsets.bottom
                
                if self.collectionView.contentSize.height > self.collectionView.frame.height - (keyboardFrame.height + self.customInputView.frame.height) {
                    self.view.transform = CGAffineTransform(translationX: 0,
                                                                      y: -keyboardFrame.height + bottomInset)
                } else {
                    self.customInputView.transform = CGAffineTransform(translationX: 0,
                                                                       y: -keyboardFrame.height + bottomInset)
                }
                
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] noti in
                guard let self = self else { return }
                let keyboardFrame = self.getKeyboardFrame(noti: noti)

                if self.collectionView.contentSize.height > self.collectionView.frame.height - (keyboardFrame.height + self.customInputView.frame.height) {
                    self.view.transform = .identity
                }
                self.customInputView.transform = .identity
            })
            .disposed(by: disposeBag)
        
    }
    
    
    // MARK: - Helper
    func getKeyboardFrame(noti: Notification) -> CGRect {
        guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            fatalError()
        }
        let keyboardFrame = value.cgRectValue
        return keyboardFrame
    }
}
