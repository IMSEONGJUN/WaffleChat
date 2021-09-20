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

protocol ChatViewModelBindable: ViewModelType {
    // Input
    var userData: BehaviorRelay<User?> { get }
    var inputText: BehaviorRelay<String> { get }
    var sendButtonTapped: PublishSubject<Void> { get }
    
    // Output
    var isMessageUploaded: Driver<Bool> { get }
    var messages: BehaviorRelay<[Message]> { get }
}

final class ChatController: UIViewController, ViewType {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    private let customInputView = CustomInputAccessoryView()
    var viewModel: ChatViewModelBindable!
    var disposeBag: DisposeBag!
    
    private let tapGesture = UITapGestureRecognizer()
    private let coverView = UIView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let lengthToScroll = collectionView.contentSize.height - collectionView.frame.height
            collectionView.contentOffset.y = lengthToScroll
        }
        coverView.removeFromSuperview()
    }
    
    
    // MARK: - Initial UI Setup
    func setupUI() {
        configureCollectionView()
        configureCustomInputView()
        configureTapGesture()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
    }
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 50)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
    
    private func configureCustomInputView() {
        view.addSubview(customInputView)
        customInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
    }
    
    private func configureTapGesture() {
        collectionView.addGestureRecognizer(tapGesture)
    }
    
//    override var inputAccessoryView: UIView? {
//        return customInputView
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    // MARK: - Binding
    func bind() {
        // Input -> ViewModel
         customInputView.sendButton.rx.tap
             .bind(to: viewModel.sendButtonTapped)
             .disposed(by: disposeBag)
         
         customInputView.messageInputTextView.rx.text
             .orEmpty
             .distinctUntilChanged()
             .bind(to: viewModel.inputText)
             .disposed(by: disposeBag)
        
        
        // ViewModel -> Output
        viewModel.userData
            .compactMap { $0 }
            .subscribe(with: self) { owner, user in
                owner.configureNavigationBar(with: user.username, prefersLargeTitles: false)
            }
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                viewModel.messages,
                viewModel.userData
            )
            .map{ messages, user -> [Message] in
                return messages.map { Message(original: $0, user: user!) }
            }
            .bind(to: collectionView.rx.items(cellIdentifier: MessageCell.reuseID,
                                              cellType: MessageCell.self)) { index, message, cell in
                cell.message = message
            }
            .disposed(by: disposeBag)

        viewModel.isMessageUploaded
            .filter { $0 }
            .drive(with: self) { owner, _ in
                owner.customInputView.clearMessageText()
            }
            .disposed(by: disposeBag)
       
        
        // UI Binding
        tapGesture.rx.event
            .subscribe(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        
        // Notification Binding
        NotificationCenter.default.rx.notification(Notifications.didFinishFetchMessage)
            .withLatestFrom(viewModel.messages)
            .map { $0.count }
            .subscribe(with: self) { owner, messageCount in
                if (owner.collectionView.contentSize.height + owner.topbarHeight) > owner.collectionView.frame.height {
                    owner.collectionView.scrollToItem(at: IndexPath(item: messageCount - 1, section: 0), at: .bottom, animated: true)
                    owner.collectionView.layoutIfNeeded()
                }
            }
            .disposed(by: disposeBag)
        
        Observable.merge(
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        )
        .subscribe(with: self) { owner, noti in
            owner.updateMessageLayout(noti: noti)
        }
        .disposed(by: disposeBag)
    }
    
    
    // MARK: - Helper
    private func getKeyboardFrameHeight(noti: Notification) -> CGFloat {
        guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            fatalError()
        }
        let keyboardFrame = value.cgRectValue
        return keyboardFrame.height
    }
    
    private func updateMessageLayout(noti: Notification) {
        let height = getKeyboardFrameHeight(noti: noti)
        let isKeyboardWillShow = noti.name == UIResponder.keyboardWillHideNotification
        if collectionView.contentSize.height + topbarHeight > view.frame.height - (height + customInputView.frame.height) {
            view.transform = isKeyboardWillShow
                ? CGAffineTransform(translationX: 0, y: -height + view.safeAreaInsets.bottom) : .identity
            return
        }
        customInputView.transform = isKeyboardWillShow
            ? CGAffineTransform(translationX: 0, y: -height + view.safeAreaInsets.bottom) : .identity
    }
}









//if (self.collectionView.contentSize.height + self.topbarHeight) > self.collectionView.frame.height {
//    let lengthToScroll = (self.collectionView.contentSize.height + self.topbarHeight) - self.collectionView.contentSize.height
//    self.collectionView.contentOffset.y = lengthToScroll + 32
/// CollectionView ContentOffSet Reference
///   let divisionIntValue = Int(collectionViewContentHeight / collectionViewHeight)
///   let remainder = collectionViewContentHeight.truncatingRemainder(dividingBy: collectionViewHeight)

// MARK: - Override
//    override var inputAccessoryView: UIView? {
//        return customInputView
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }

//                let count = self.viewModel.messages.value.count
//                self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
//                self.collectionView.layoutIfNeeded()
